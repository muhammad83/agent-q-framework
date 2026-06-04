#!/usr/bin/env python3
"""
estimate-plan.py — forecast the token + $ cost of running a build plan, BEFORE you run it.

token-burn.py is the post-mortem ("what burned tokens last session?"). This is the
pre-flight: given a `workflows/build-plan-*.md`, it reads the plan's file list, measures
the real size of every file the run will READ, and models the no-cache cumulative
exposure — the same "size × turns-it-stays-in-context" weighting token-burn.py uses, so
the forecast and the post-mortem speak the same language.

Why no-cache makes this matter: with prompt caching off (Bedrock Sonnet 4.x), every token
in context is re-sent and re-billed at full input price on EVERY turn. A 5k-token file read
on turn 1 of a 40-turn run effectively costs ~5k × 40 = 200k input tokens. Plans that
front-load many reads "blow up." This tool surfaces that before you pay for it.

All figures are ESTIMATES (chars/4 for size; a turns-per-task multiplier for exposure).
Run token-burn.py on a comparable past session to calibrate the scale, and the printed
ccusage ground-truth gives you today's real spend to anchor against.

Usage:
    estimate-plan.py workflows/build-plan-token-economy.md
    estimate-plan.py <plan.md> --turns-per-task 8     # heavier turn assumption
    estimate-plan.py <plan.md> --json                 # machine-readable (skill consumption)
    estimate-plan.py <plan.md> --top 15               # more cost-driver rows

Config (env, all optional — defaults shown):
    Q_INPUT_PRICE_PER_M   (3)     input price per 1M tokens
    Q_OUTPUT_PRICE_PER_M  (15)    output price per 1M tokens
    Q_DAILY_BUDGET_USD    (40)    daily budget, shown for context / split cap default
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
from dataclasses import dataclass, field
from glob import glob
from pathlib import Path

# ── ANSI (matches the token-burn.py / HUD palette) ──────────────
def _c(r: int, g: int, b: int) -> str:
    return f"\033[38;2;{r};{g};{b}m"


BLUE, GREEN, CYAN = _c(0, 153, 255), _c(0, 175, 80), _c(86, 182, 194)
RED, ORANGE, YELLOW = _c(255, 85, 85), _c(255, 176, 85), _c(230, 200, 0)
WHITE, DIM, RESET, BOLD = _c(220, 220, 220), "\033[2m", "\033[0m", "\033[1m"

# ── Defaults (config-driven, nothing cost-relevant hardcoded in logic) ──
DEF_TURNS_PER_TASK = 6      # turns a single task burns end-to-end
DEF_OVERHEAD_TOK = 12_000   # framework + system prompt re-sent every turn (no cache)
DEF_OUTPUT_PER_TURN = 2_000  # assistant output tokens per turn
BIG_FILE_TOK = 6_000        # a read this large is a sub-agent / partial-read candidate

# Exposure factors: how many turns, on average, a read file stays billable.
# low = reads done just-in-time / a /compact halfway; high = front-loaded + re-reads.
F_LOW, F_EXPECTED, F_HIGH = 0.5, 0.8, 1.1


def fmt_tok(n: float) -> str:
    n = int(n)
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}m"
    if n >= 1_000:
        return f"{n / 1_000:.0f}k"
    return str(n)


def color_for(frac: float) -> str:
    if frac >= 0.30:
        return RED
    if frac >= 0.15:
        return ORANGE
    if frac >= 0.05:
        return YELLOW
    return GREEN


def bar(frac: float, width: int = 20) -> str:
    filled = int(round(frac * width))
    return color_for(frac) + "█" * filled + DIM + "·" * (width - filled) + RESET


# ── Plan parsing ────────────────────────────────────────────────
BACKTICK = re.compile(r"`([^`]+)`")
TASK_HEADING = re.compile(r"^#{2,3}\s+Task\s+\d+", re.IGNORECASE)
SECTION_MARK = re.compile(r"\*\*\s*(create|modify|delete)\s*:?\s*\*\*", re.IGNORECASE)
ANY_BOLD_MARK = re.compile(r"^\s*\*\*[^*]+:?\*\*")
BULLET = re.compile(r"^\s*[-*]\s+")
PATHISH = re.compile(r"^[\w][\w./\-]*$")


@dataclass
class PlanModel:
    plan_path: Path
    task_count: int
    create: set[str] = field(default_factory=set)
    modify: set[str] = field(default_factory=set)
    delete: set[str] = field(default_factory=set)
    referenced: set[str] = field(default_factory=set)


def looks_like_path(token: str) -> bool:
    """A backtick token is path-ish if it has no spaces and carries a dir or extension."""
    token = token.strip()
    if not PATHISH.match(token):
        return False
    return "/" in token or "." in token.rsplit("/", 1)[-1]


def parse_plan(text: str, plan_path: Path) -> PlanModel:
    model = PlanModel(plan_path=plan_path, task_count=0)
    mode: str | None = None
    for raw in text.splitlines():
        line = raw.rstrip()

        if TASK_HEADING.match(line):
            model.task_count += 1
            mode = None
            continue
        if line.startswith("## "):
            mode = None  # left a task body

        sect = SECTION_MARK.search(line)
        if sect:
            mode = sect.group(1).lower()
        elif ANY_BOLD_MARK.match(line):
            mode = None  # a different bold marker (Verify:, Commit:, Goal:) ends the list

        # Collect every path-ish backtick token as a "referenced" path.
        for tok in BACKTICK.findall(line):
            tok = tok.strip()
            if looks_like_path(tok):
                model.referenced.add(tok)

        # Bullet under an active Create/Modify/Delete section → that section's file.
        if mode and BULLET.match(line):
            for tok in BACKTICK.findall(line):
                tok = tok.strip()
                if looks_like_path(tok):
                    getattr(model, mode).add(tok)
                    break  # first backtick on the bullet is the file; rest is prose
    return model


def resolve(token: str, bases: list[Path]) -> Path | None:
    """Find an existing file for a plan-relative path token across candidate roots."""
    for base in bases:
        cand = (base / token).resolve()
        if cand.is_file():
            return cand
    return None


# ── Cost model ──────────────────────────────────────────────────
@dataclass
class Driver:
    label: str
    kind: str          # "read" | "overhead" | "output"
    tokens: float      # cumulative (exposure-weighted) tokens at the expected factor
    price_per_m: float

    @property
    def cost(self) -> float:
        return self.tokens / 1_000_000 * self.price_per_m


def build_estimate(model: PlanModel, args: argparse.Namespace) -> dict:
    bases = [
        Path.cwd(),
        model.plan_path.parent,
        model.plan_path.parent.parent,  # plan lives in workflows/ → repo root
    ]
    in_price = float(os.environ.get("Q_INPUT_PRICE_PER_M", "3"))
    out_price = float(os.environ.get("Q_OUTPUT_PRICE_PER_M", "15"))

    tasks = model.task_count or 1
    turns = max(int(round(tasks * args.turns_per_task)), 1)

    # Files the run will READ: modify targets + referenced paths that exist on disk,
    # minus anything the plan creates/deletes. Created files don't exist to read.
    read_candidates = (model.modify | model.referenced) - model.create - model.delete
    reads: list[tuple[str, float]] = []
    seen: set[str] = set()
    for tok in sorted(read_candidates):
        path = resolve(tok, bases)
        if not path or str(path) in seen:
            continue
        seen.add(str(path))
        toks = path.stat().st_size / 4.0  # bytes/4 ≈ tokens, matches token-burn's chars/4
        reads.append((tok, toks))
    reads.sort(key=lambda r: r[1], reverse=True)

    read_tok = sum(t for _, t in reads)
    overhead_total = args.overhead * turns       # re-billed every turn (no cache)
    output_total = args.output_per_turn * turns  # billed at output price

    def input_tokens(f: float) -> float:
        return read_tok * f + overhead_total

    def total_cost(f: float) -> float:
        return input_tokens(f) / 1e6 * in_price + output_total / 1e6 * out_price

    def total_tokens(f: float) -> float:
        return input_tokens(f) + output_total

    # Cost drivers at the expected exposure factor.
    drivers = [
        Driver(label, "read", toks * F_EXPECTED, in_price) for label, toks in reads
    ]
    drivers.append(Driver("framework + system overhead", "overhead", overhead_total, in_price))
    drivers.append(Driver("model output", "output", output_total, out_price))
    drivers.sort(key=lambda d: d.cost, reverse=True)

    budget = float(os.environ.get("Q_DAILY_BUDGET_USD", "40"))
    cap = args.cap if args.cap is not None else round(budget * 0.15, 2)

    return {
        "plan": str(model.plan_path),
        "tasks": model.task_count,
        "turns": turns,
        "turns_per_task": args.turns_per_task,
        "reads": reads,
        "read_tokens": read_tok,
        "overhead_total": overhead_total,
        "output_total": output_total,
        "in_price": in_price,
        "out_price": out_price,
        "cap": cap,
        "budget": budget,
        "low": {"tokens": total_tokens(F_LOW), "cost": total_cost(F_LOW)},
        "expected": {"tokens": total_tokens(F_EXPECTED), "cost": total_cost(F_EXPECTED)},
        "high": {"tokens": total_tokens(F_HIGH), "cost": total_cost(F_HIGH)},
        "drivers": drivers,
        "low_confidence": not reads,
    }


def recommendations(est: dict) -> list[str]:
    recs: list[str] = []
    total_in = est["read_tokens"] * F_EXPECTED + est["overhead_total"]

    for label, toks in est["reads"]:
        weighted = toks * F_EXPECTED
        share = weighted / total_in if total_in else 0
        if toks >= BIG_FILE_TOK or share >= 0.15:
            recs.append(
                f"{label} is {fmt_tok(toks)} tok (~{share*100:.0f}% of input over the run) — "
                f"read it partially (Read offset/limit) or push it into a sub-agent so the "
                f"content dies with the sub-agent instead of re-billing every turn."
            )

    if est["tasks"] > 3:
        recs.append(
            f"{est['tasks']} tasks — split into ≤3-task chunks (context-budget rule) and run "
            f"each as its own /q:execute with /clear between, or parallelize via /q:spinjitsu."
        )

    if est["expected"]["cost"] > est["cap"]:
        recs.append(
            f"expected ${est['expected']['cost']:.2f} > single-run cap ${est['cap']:.2f} — "
            f"split into separate /clear sessions or spinjitsu worktrees (fresh context each)."
        )

    if est["turns"] >= 15:
        recs.append(
            f"~{est['turns']} turns is long for no-cache — /compact once the heaviest reads are "
            f"done (their content stops re-billing after the summary replaces them)."
        )

    if est["low_confidence"]:
        recs.append(
            "no readable file list found in the plan — estimate is task-count-only and "
            "low-confidence. Add a `**Create:**/**Modify:**` file list to the plan for accuracy."
        )

    if not recs:
        recs.append("plan looks lean for a no-cache run — no front-loaded heavy reads detected.")
    return recs


# ── ccusage ground-truth (calibration anchor; degrades silently) ──
def ccusage_today() -> float | None:
    import shutil
    import subprocess

    exe = shutil.which("ccusage") or os.path.expanduser("~/.bun/bin/ccusage")
    if not (os.path.isfile(exe) or shutil.which("ccusage")):
        return None
    try:
        out = subprocess.run(
            [exe, "daily", "--json"], capture_output=True, text=True, timeout=15
        )
        data = json.loads(out.stdout or "{}")
        daily = data.get("daily") or []
        if daily:
            return float(daily[-1].get("totalCost", 0) or 0)
    except (OSError, ValueError, subprocess.SubprocessError):
        return None
    return None


# ── Reporting ───────────────────────────────────────────────────
def report(est: dict, top: int) -> None:
    print(f"{BOLD}{CYAN}estimate-plan{RESET}  {DIM}{est['plan']}{RESET}")
    conf = f"{ORANGE}low-confidence (no file list){RESET}" if est["low_confidence"] else \
           f"{GREEN}{len(est['reads'])} files measured{RESET}"
    print(f"{WHITE}plan{RESET}  {est['tasks']} tasks  {DIM}·{RESET}  "
          f"~{est['turns']} turns  {DIM}(×{est['turns_per_task']}/task){RESET}  "
          f"{DIM}·{RESET}  {conf}")
    print()

    e = est["expected"]
    print(f"{BOLD}Forecast{RESET} {DIM}(no-cache cumulative exposure){RESET}")
    print(f"  {WHITE}expected{RESET}  {GREEN}${e['cost']:.2f}{RESET}  "
          f"{DIM}~{fmt_tok(e['tokens'])} tokens{RESET}")
    print(f"  {DIM}range     ${est['low']['cost']:.2f} – ${est['high']['cost']:.2f}  "
          f"({fmt_tok(est['low']['tokens'])} – {fmt_tok(est['high']['tokens'])} tok){RESET}")
    cap_clr = RED if e["cost"] > est["cap"] else GREEN
    print(f"  {DIM}vs cap    {cap_clr}${est['cap']:.2f}/run{RESET}{DIM} · "
          f"${est['budget']:.0f}/day budget{RESET}")
    print()

    total_cost = sum(d.cost for d in est["drivers"]) or 1e-9
    print(f"{BOLD}Top cost drivers{RESET} {DIM}(exposure-weighted, expected case){RESET}")
    for d in est["drivers"][:top]:
        frac = d.cost / total_cost
        tag = {"read": WHITE, "overhead": YELLOW, "output": BLUE}[d.kind]
        print(f"  {bar(frac)} {color_for(frac)}${d.cost:>6.2f}{RESET} "
              f"{DIM}({fmt_tok(d.tokens)} tok){RESET}  {tag}{d.label}{RESET}")
    print()

    print(f"{BOLD}Recommendations{RESET}")
    for rec in recommendations(est):
        print(f"  {CYAN}•{RESET} {rec}")

    actual = ccusage_today()
    print()
    if actual is not None:
        print(f"{DIM}Ground truth: ccusage says you've spent {GREEN}${actual:.2f}{RESET}{DIM} "
              f"today. Calibrate this forecast against it, and run "
              f"tools/token-burn.py on a past session to validate the per-turn model.{RESET}")
    else:
        print(f"{DIM}Ground truth: install ccusage (bun add -g ccusage) to anchor estimates "
              f"against real spend; run tools/token-burn.py on a past session to calibrate "
              f"the per-turn model.{RESET}")


def to_json(est: dict) -> str:
    out = {
        k: est[k] for k in (
            "plan", "tasks", "turns", "turns_per_task", "read_tokens",
            "overhead_total", "output_total", "in_price", "out_price",
            "cap", "budget", "low", "expected", "high", "low_confidence",
        )
    }
    out["reads"] = [{"file": label, "tokens": round(toks)} for label, toks in est["reads"]]
    out["drivers"] = [
        {"label": d.label, "kind": d.kind, "tokens": round(d.tokens),
         "cost": round(d.cost, 4)}
        for d in est["drivers"]
    ]
    out["recommendations"] = recommendations(est)
    actual = ccusage_today()
    out["ccusage_today"] = round(actual, 2) if actual is not None else None
    return json.dumps(out, indent=2)


def resolve_plan_arg(arg: str) -> Path | None:
    p = Path(arg)
    if p.is_file():
        return p
    # allow a bare feature name → workflows/build-plan-<name>.md
    for cand in (
        Path("workflows") / arg,
        Path("workflows") / f"build-plan-{arg}.md",
    ):
        if cand.is_file():
            return cand
    matches = glob(f"workflows/build-plan-*{arg}*.md")
    return Path(matches[0]) if matches else None


def main() -> None:
    ap = argparse.ArgumentParser(
        description="Forecast token + $ cost of a build plan before running it (no-cache model).")
    ap.add_argument("plan", help="path to a build-plan-*.md (or a feature name under workflows/)")
    ap.add_argument("--turns-per-task", type=float, default=DEF_TURNS_PER_TASK,
                    help=f"turns each task burns (default {DEF_TURNS_PER_TASK})")
    ap.add_argument("--overhead", type=float, default=DEF_OVERHEAD_TOK,
                    help=f"per-turn framework/system tokens (default {DEF_OVERHEAD_TOK})")
    ap.add_argument("--output-per-turn", type=float, default=DEF_OUTPUT_PER_TURN,
                    help=f"output tokens per turn (default {DEF_OUTPUT_PER_TURN})")
    ap.add_argument("--cap", type=float, default=None,
                    help="single-run $ cap for the split recommendation (default 15%% of daily budget)")
    ap.add_argument("--top", type=int, default=10, help="cost-driver rows to show (default 10)")
    ap.add_argument("--json", action="store_true", help="machine-readable output")
    args = ap.parse_args()

    plan_path = resolve_plan_arg(args.plan)
    if not plan_path:
        sys.exit(f"Plan not found: {args.plan}")

    text = plan_path.read_text(errors="replace")
    model = parse_plan(text, plan_path)
    est = build_estimate(model, args)

    if args.json:
        print(to_json(est))
    else:
        report(est, args.top)


if __name__ == "__main__":
    main()
