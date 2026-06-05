#!/usr/bin/env python3
"""
token-burn.py — answer "what burned the most tokens?" *within* a Claude Code session.

ccusage tells you WHICH conversation and WHICH model burned tokens. This tells you
WHAT inside a conversation did it: which tool, which file read, which command output.

The dominant cost in a long session is not any single big output — it's that every
tool result stays in the context window and gets re-read (as cache-read tokens) on
every subsequent turn. So a 5k-token file read early in a 40-turn session effectively
costs ~5k * 40 = 200k cumulative cache-read tokens. This tool models that exposure and
ranks tool outputs by their cumulative token weight.

Token figures are ESTIMATES (chars/4 for tool-result size; turn-count multiplier for
cache exposure). The session's true cache-read total (from the API usage records) is
printed as ground truth so you can sanity-check the scale.

Usage:
    token-burn.py                       # analyze the most recent session in CWD's project
    token-burn.py <file.jsonl>          # analyze a specific session log
    token-burn.py --project safqore     # most recent session whose project path matches
    token-burn.py --top 25              # show more rows
    token-burn.py --all                 # rank the heaviest sessions first, then pick one
"""
import argparse
import json
import os
import sys
from collections import defaultdict
from glob import glob

PROJECTS_DIR = os.path.expanduser("~/.claude/projects")
CODEX_GLOBS = [
    os.path.expanduser("~/.codex/sessions/**/*.jsonl"),
    os.path.expanduser("~/.codex/archived_sessions/*.jsonl"),
]

# ── ANSI (matches the HUD palette) ──────────────────────────────
def _c(r, g, b):
    return f"\033[38;2;{r};{g};{b}m"
BLUE, GREEN, CYAN = _c(0, 153, 255), _c(0, 175, 80), _c(86, 182, 194)
RED, ORANGE, YELLOW = _c(255, 85, 85), _c(255, 176, 85), _c(230, 200, 0)
WHITE, DIM, RESET = _c(220, 220, 220), "\033[2m", "\033[0m"
BOLD = "\033[1m"


def fmt_tok(n):
    n = int(n)
    if n >= 1_000_000:
        return f"{n/1_000_000:.1f}m"
    if n >= 1_000:
        return f"{n/1_000:.0f}k"
    return str(n)


def color_for(frac):
    if frac >= 0.30:
        return RED
    if frac >= 0.15:
        return ORANGE
    if frac >= 0.05:
        return YELLOW
    return GREEN


def content_chars(content):
    """Approximate the serialized size of a tool_result's content."""
    if isinstance(content, str):
        return len(content)
    try:
        return len(json.dumps(content, ensure_ascii=False))
    except (TypeError, ValueError):
        return len(str(content))


def short_label(name, inp):
    """A human-readable label for a tool call: file for file tools, first token for Bash."""
    if not isinstance(inp, dict):
        return name
    if name in ("Read", "Edit", "Write", "NotebookEdit") and inp.get("file_path"):
        return f"{name}({os.path.basename(inp['file_path'])})"
    if name == "Bash" and inp.get("command"):
        cmd = inp["command"].strip().split()
        head = " ".join(cmd[:2]) if cmd else ""
        return f"Bash({head})"
    if name in ("Grep", "Glob") and (inp.get("pattern") or inp.get("query")):
        return f"{name}({inp.get('pattern') or inp.get('query')})"
    if name.startswith("mcp__"):
        return name
    return name


def server_of(mcp_tool):
    # mcp__claude_ai_Gmail__search_threads -> claude_ai_Gmail
    parts = mcp_tool.split("__")
    return parts[1] if len(parts) >= 2 else mcp_tool


def _select(files, args, label):
    if not files:
        sys.exit(f"No {label} session logs found")
    if args.all:
        ranked = sorted(files, key=lambda f: os.path.getsize(f), reverse=True)
        print(f"{BOLD}Heaviest {label} session logs (by file size):{RESET}")
        for f in ranked[:12]:
            print(f"  {fmt_tok(os.path.getsize(f)):>6}b  {DIM}{f}{RESET}")
        print()
        return ranked[0]
    return max(files, key=os.path.getmtime)


def find_session(args):
    if args.file:
        return args.file
    if getattr(args, "codex", False):
        files = []
        for g in CODEX_GLOBS:
            files += glob(g, recursive=True)
        if args.project:
            files = [f for f in files if args.project.lower() in f.lower()]
        return _select(files, args, "Codex")
    pattern = os.path.join(PROJECTS_DIR, "**", "*.jsonl")
    files = [f for f in glob(pattern, recursive=True) if "/subagents/" not in f]
    if args.project:
        files = [f for f in files if args.project.lower() in f.lower()]
    else:
        cwd_key = os.getcwd().replace("/", "-")
        match = [f for f in files if cwd_key in f]
        if match:
            files = match
    return _select(files, args, "Claude")


def detect_format(path):
    """Sniff the first JSON line: Codex rollouts are {payload, type, timestamp}."""
    try:
        with open(path, errors="replace") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                obj = json.loads(line)
                if isinstance(obj, dict) and "payload" in obj and "timestamp" in obj:
                    return "codex"
                return "claude"
    except (OSError, json.JSONDecodeError):
        pass
    return "claude"


def short_label_codex(name, args):
    if name == "exec_command" and isinstance(args, dict):
        cmd = (args.get("cmd") or "").strip().split()
        head = " ".join(cmd[:2]) if cmd else ""
        return f"exec({head})" if head else "exec_command"
    if name == "apply_patch" and isinstance(args, dict):
        return f"apply_patch({os.path.basename(args.get('path',''))})" if args.get("path") else "apply_patch"
    return name or "(tool)"


def analyze_codex(path):
    """Codex rollout parser — same output shape as analyze() for report()."""
    parsed = []
    with open(path, "r", errors="replace") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                e = json.loads(line)
            except json.JSONDecodeError:
                continue
            p = e.get("payload") or {}
            parsed.append((e.get("type"), p.get("type"), p))

    # Pass 1: count model turns (one token_count per model call) and grab cumulative usage.
    total_turns = 0
    usage = {"input": 0, "output": 0, "cache_read": 0, "cache_create": 0}
    for t, pt, p in parsed:
        if t == "event_msg" and pt == "token_count":
            total_turns += 1
            info = (p.get("info") or {}).get("total_token_usage") or {}
            cached = info.get("cached_input_tokens", 0)
            # Codex input_tokens is cumulative and *includes* the cached portion;
            # split it so report()'s real = cache_read + input + output stays correct.
            usage["cache_read"] = cached
            usage["input"] = max(info.get("input_tokens", 0) - cached, 0)
            usage["output"] = info.get("output_tokens", 0) + info.get("reasoning_output_tokens", 0)

    # Pass 2: attribute tool outputs, weighting by turns they stay in context.
    seen = 0
    calls = {}
    by_tool = defaultdict(lambda: {"calls": 0, "raw": 0, "weighted": 0})
    by_label = defaultdict(lambda: {"calls": 0, "raw": 0, "weighted": 0})
    mcp_calls = defaultdict(int)
    rows = []

    def add(name, label, chars):
        toks = chars / 4.0
        exposure = max(total_turns - seen, 0)
        weighted = toks * (exposure + 1)
        by_tool[name]["calls"] += 1
        by_tool[name]["raw"] += toks
        by_tool[name]["weighted"] += weighted
        by_label[label]["calls"] += 1
        by_label[label]["raw"] += toks
        by_label[label]["weighted"] += weighted
        rows.append((weighted, toks, exposure, label, name))

    for t, pt, p in parsed:
        if t == "event_msg" and pt == "token_count":
            seen += 1
        elif pt in ("function_call", "custom_tool_call"):
            args = p.get("arguments") if "arguments" in p else p.get("input")
            if isinstance(args, str):
                try:
                    args = json.loads(args)
                except json.JSONDecodeError:
                    args = {"_raw": args}
            calls[p.get("call_id")] = (p.get("name", "?"), args)
        elif pt in ("function_call_output", "custom_tool_call_output"):
            name, args = calls.get(p.get("call_id"), ("(unknown)", {}))
            add(name, short_label_codex(name, args), content_chars(p.get("output", "")))
        elif t == "event_msg" and pt == "mcp_tool_call_end":
            inv = p.get("invocation") or {}
            srv = inv.get("server") or "mcp"
            mcp_calls[srv] += 1
            add(f"mcp__{srv}", f"mcp:{srv}.{inv.get('tool', '')}", content_chars(p.get("result", "")))

    return {
        "path": path, "turns": total_turns, "usage": usage,
        "by_tool": by_tool, "by_label": by_label, "mcp_calls": mcp_calls, "rows": rows,
    }


def analyze(path):
    entries = []
    with open(path, "r", errors="replace") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                entries.append(json.loads(line))
            except json.JSONDecodeError:
                continue

    # First pass: index tool_use blocks and count assistant turns in order.
    assistant_turns = 0
    tool_use = {}          # id -> (name, input, turn_seen_before)
    usage = {"input": 0, "output": 0, "cache_read": 0, "cache_create": 0}
    order = []             # flat ordered list of ("assistant", None) / ("result", id, chars)

    for e in entries:
        if e.get("type") == "assistant":
            assistant_turns += 1
            u = (e.get("message") or {}).get("usage") or {}
            usage["input"] += u.get("input_tokens", 0)
            usage["output"] += u.get("output_tokens", 0)
            usage["cache_read"] += u.get("cache_read_input_tokens", 0)
            usage["cache_create"] += u.get("cache_creation_input_tokens", 0)
            for blk in (e.get("message") or {}).get("content", []) or []:
                if isinstance(blk, dict) and blk.get("type") == "tool_use":
                    tool_use[blk.get("id")] = (blk.get("name", "?"), blk.get("input", {}))
            order.append(("assistant", None, 0))
        elif e.get("type") == "user":
            for blk in (e.get("message") or {}).get("content", []) or []:
                if isinstance(blk, dict) and blk.get("type") == "tool_result":
                    chars = content_chars(blk.get("content", ""))
                    order.append(("result", blk.get("tool_use_id"), chars))

    total_turns = assistant_turns

    # Second pass over `order`: assign each result a cache-exposure = #assistant turns after it.
    seen_turns = 0
    by_tool = defaultdict(lambda: {"calls": 0, "raw": 0, "weighted": 0})
    by_label = defaultdict(lambda: {"calls": 0, "raw": 0, "weighted": 0})
    mcp_calls = defaultdict(int)
    rows = []

    for kind, ref, chars in order:
        if kind == "assistant":
            seen_turns += 1
            continue
        name, inp = tool_use.get(ref, ("(unknown)", {}))
        toks = chars / 4.0
        exposure = max(total_turns - seen_turns, 0)        # future turns that re-read it
        weighted = toks * (exposure + 1)                   # +1 = the turn that first read it
        by_tool[name]["calls"] += 1
        by_tool[name]["raw"] += toks
        by_tool[name]["weighted"] += weighted
        label = short_label(name, inp)
        by_label[label]["calls"] += 1
        by_label[label]["raw"] += toks
        by_label[label]["weighted"] += weighted
        if name.startswith("mcp__"):
            mcp_calls[server_of(name)] += 1
        rows.append((weighted, toks, exposure, label, name))

    return {
        "path": path, "turns": total_turns, "usage": usage,
        "by_tool": by_tool, "by_label": by_label, "mcp_calls": mcp_calls, "rows": rows,
    }


def bar(frac, width=20):
    filled = int(round(frac * width))
    return color_for(frac) + "█" * filled + DIM + "·" * (width - filled) + RESET


def report(data, top):
    print(f"{BOLD}{CYAN}token-burn{RESET}  {DIM}{data['path']}{RESET}")
    u = data["usage"]
    real = u["cache_read"] + u["input"] + u["output"]
    print(f"{WHITE}session{RESET}  {data['turns']} assistant turns  {DIM}·{RESET}  "
          f"{GREEN}{fmt_tok(real)}{RESET} real tokens "
          f"{DIM}({fmt_tok(u['cache_read'])} cache-read · {fmt_tok(u['input'])} in · "
          f"{fmt_tok(u['output'])} out){RESET}")
    if real:
        cr_frac = u["cache_read"] / real
        print(f"         {RED if cr_frac>=0.8 else ORANGE}{cr_frac*100:.0f}% of tokens are "
              f"cache re-reads{RESET} {DIM}— this is what session length costs you{RESET}")
    print()

    total_w = sum(r[0] for r in data["rows"]) or 1

    print(f"{BOLD}Heaviest tool outputs{RESET} {DIM}(weighted = est. tokens × turns it stayed "
          f"in context){RESET}")
    for weighted, toks, exposure, label, name in sorted(data["rows"], reverse=True)[:top]:
        frac = weighted / total_w
        print(f"  {bar(frac)} {color_for(frac)}{fmt_tok(weighted):>6}{RESET} "
              f"{DIM}({fmt_tok(toks)} ×{exposure+1} turns){RESET}  {WHITE}{label}{RESET}")
    print()

    print(f"{BOLD}By tool type{RESET}")
    tools = sorted(data["by_tool"].items(), key=lambda kv: kv[1]["weighted"], reverse=True)
    for name, s in tools:
        frac = s["weighted"] / total_w
        print(f"  {bar(frac, 16)} {color_for(frac)}{fmt_tok(s['weighted']):>6}{RESET}  "
              f"{WHITE}{name}{RESET} {DIM}({s['calls']} calls, {fmt_tok(s['raw'])} raw){RESET}")
    print()

    print(f"{BOLD}Worst single offenders{RESET} {DIM}(by label, weighted){RESET}")
    labels = sorted(data["by_label"].items(), key=lambda kv: kv[1]["weighted"], reverse=True)
    for label, s in labels[:top]:
        frac = s["weighted"] / total_w
        print(f"  {color_for(frac)}{fmt_tok(s['weighted']):>6}{RESET}  {WHITE}{label}{RESET} "
              f"{DIM}(×{s['calls']}){RESET}")

    if data["mcp_calls"]:
        print(f"\n{BOLD}MCP tool calls this session{RESET}")
        for srv, n in sorted(data["mcp_calls"].items(), key=lambda kv: -kv[1]):
            print(f"  {YELLOW}{n:>4}{RESET}  {WHITE}{srv}{RESET}")
    else:
        print(f"\n{DIM}No MCP tools were called this session.{RESET}")

    print(f"\n{DIM}Lever: at {round((u['cache_read']/real*100) if real else 0)}% cache re-reads, "
          f"the cheapest win is shorter sessions — /clear or /compact once a task is done.{RESET}")


def main():
    ap = argparse.ArgumentParser(description="Analyze where tokens are burned within a Claude Code session.")
    ap.add_argument("file", nargs="?", help="session .jsonl (default: most recent for CWD's project)")
    ap.add_argument("--project", help="substring to match a project path")
    ap.add_argument("--top", type=int, default=15, help="rows to show (default 15)")
    ap.add_argument("--all", action="store_true", help="list heaviest sessions, analyze the biggest")
    ap.add_argument("--codex", action="store_true", help="analyze OpenAI Codex logs (~/.codex) instead of Claude Code")
    args = ap.parse_args()
    path = find_session(args)
    fmt = "codex" if args.codex else detect_format(path)
    report(analyze_codex(path) if fmt == "codex" else analyze(path), args.top)


if __name__ == "__main__":
    main()
