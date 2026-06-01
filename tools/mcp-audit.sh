#!/bin/bash
# mcp-audit.sh — surface connected-but-unused MCP servers.
#
# Cross-references the MCP servers Claude Code currently connects to against
# every tool call ever recorded (~/.claude.json toolUsage + all session logs),
# and flags servers whose tools have never been invoked.
#
# Why this matters: unused MCPs cost you startup health-check latency, auth
# prompts, and attack surface. (In this Claude Code build, tool schemas are
# loaded on demand, so unused MCPs are NOT a big *token* cost — the real token
# burn is long sessions re-reading file contents; see token-burn.py.)
#
#   mcp-audit.sh           # report
#   mcp-audit.sh --quiet   # only print if something is unused (for hooks)
#
set -f
QUIET=0; [ "$1" = "--quiet" ] && QUIET=1

PROJECTS_DIR="$HOME/.claude/projects"
CLAUDE_JSON="$HOME/.claude.json"

green='\033[38;2;0;175;80m'; red='\033[38;2;255;85;85m'
orange='\033[38;2;255;176;85m'; yellow='\033[38;2;230;200;0m'
white='\033[38;2;220;220;220m'; cyan='\033[38;2;86;182;194m'
dim='\033[2m'; bold='\033[1m'; reset='\033[0m'

# Resolve the claude binary
CLAUDE_BIN=$(command -v claude 2>/dev/null)
[ -z "$CLAUDE_BIN" ] && for p in /opt/homebrew/bin/claude /usr/local/bin/claude "$HOME"/.nvm/versions/node/*/bin/claude; do
    [ -x "$p" ] && CLAUDE_BIN="$p" && break
done
if [ -z "$CLAUDE_BIN" ]; then echo "claude CLI not found" >&2; exit 0; fi

# 1) Connected servers. Names may contain ':' '.' ' ' (e.g. "claude.ai Gmail",
#    "plugin:vercel:vercel") — strip from the "<: transport-url>" onward only.
connected=$("$CLAUDE_BIN" mcp list 2>/dev/null \
    | sed '/^Checking/d' \
    | sed -E 's/: (https?|stdio|[A-Za-z]+:\/\/).*$//' \
    | grep -v '^[[:space:]]*$')

# 2) Count ACTUAL tool_use invocations of mcp__<server>__ across all session logs.
#    (Must parse tool_use blocks — a raw grep also catches the deferred-tool
#    listing that names every MCP tool in each session's system reminder.)
used_counts=$(
    find "$PROJECTS_DIR" -name '*.jsonl' 2>/dev/null -print0 \
    | xargs -0 cat 2>/dev/null \
    | jq -rn 'inputs | select(.type=="assistant") | (.message.content // [])[]
              | select(type=="object" and .type=="tool_use") | .name' 2>/dev/null \
    | grep '^mcp__' \
    | sed -E 's/^mcp__([A-Za-z0-9_]+)__.*/\1/' \
    | sort | uniq -c
)

# Normalize a display name -> the server token used in mcp__<token>__
#   "claude.ai Gmail" -> claude_ai_Gmail ;  "plugin:vercel:vercel" -> plugin_vercel_vercel
norm() { echo "$1" | sed -E 's/[.: ]+/_/g'; }

unused_list=""
used_any=0

report() {
    printf "${bold}${cyan}mcp-audit${reset}  ${dim}connected MCP servers vs. actual usage${reset}\n\n"
    while IFS= read -r srv; do
        [ -z "$srv" ] && continue
        token=$(norm "$srv")
        count=$(echo "$used_counts" | awk -v t="$token" '$2==t {print $1}')
        [ -z "$count" ] && count=0
        if [ "$count" -gt 0 ]; then
            used_any=1
            printf "  ${green}● used${reset}    ${white}%-26s${reset} ${dim}%s calls${reset}\n" "$srv" "$count"
        else
            unused_list+="${srv}"$'\n'
            printf "  ${red}○ UNUSED${reset} ${white}%-26s${reset} ${dim}never called${reset}\n" "$srv"
        fi
    done <<< "$connected"
}

if [ "$QUIET" = "1" ]; then
    # Build unused list silently first; only emit if non-empty.
    while IFS= read -r srv; do
        [ -z "$srv" ] && continue
        token=$(norm "$srv")
        count=$(echo "$used_counts" | awk -v t="$token" '$2==t {print $1}')
        [ -z "$count" ] && count=0
        [ "$count" -eq 0 ] && unused_list+="${srv}"$'\n'
    done <<< "$connected"
    [ -z "$unused_list" ] && exit 0
    joined=$(printf "%s" "$unused_list" | grep -v '^$' | paste -sd',' - | sed 's/,/, /g')
    printf "${orange}⚠ unused MCP servers (never called):${reset} %s" "$joined"
    printf "  ${dim}— run: agent-q-framework/tools/mcp-audit.sh${reset}\n"
    exit 0
fi

report

if [ -n "$unused_list" ]; then
    printf "\n${bold}How to disable the unused ones${reset}\n"
    printf "  ${dim}• claude.ai connectors (Gmail/Atlassian/Google*): run ${reset}${white}/mcp${reset}${dim} inside Claude\n"
    printf "    Code and disconnect, or toggle them off at claude.ai → Settings → Connectors.${reset}\n"
    printf "  ${dim}• plugin MCPs (plugin:*): disable the plugin in ~/.claude/settings.json\n"
    printf "    enabledPlugins — but note that also removes the plugin's skills.${reset}\n"
else
    printf "\n${green}All connected MCP servers are in use. Nothing to disable.${reset}\n"
fi
