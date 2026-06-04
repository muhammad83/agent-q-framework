#!/usr/bin/env bash
# commit-cost.sh — git prepare-commit-msg hook
# Appends a precise per-commit AI spend trailer: the delta in ccusage's
# lifetime cumulative cost since the previous commit.
#
#   AI-cost: $0.62 (since last commit)
#
# Install (per repo):
#   ln -sf /path/to/commit-cost.sh .git/hooks/prepare-commit-msg
#   chmod +x /path/to/commit-cost.sh
# Install (all repos):
#   git config --global core.hooksPath ~/.git-hooks
#   ln -sf /path/to/commit-cost.sh ~/.git-hooks/prepare-commit-msg
#
# Requires: ccusage (bun add -g ccusage), jq, awk. If ccusage or jq is
# missing the hook silently does nothing — it never blocks a commit.

set -euo pipefail

MSG_FILE="${1:-}"
[ -z "$MSG_FILE" ] && exit 0

# Locate ccusage (PATH or bun's global bin); bail quietly if absent.
CCUSAGE=""
if command -v ccusage >/dev/null 2>&1; then
  CCUSAGE="ccusage"
elif [ -x "$HOME/.bun/bin/ccusage" ]; then
  CCUSAGE="$HOME/.bun/bin/ccusage"
fi
[ -z "$CCUSAGE" ] && exit 0
command -v jq  >/dev/null 2>&1 || exit 0
command -v awk >/dev/null 2>&1 || exit 0

# State file holds the last-recorded cumulative total (one float per line).
STATE="${COMMIT_COST_STATE:-$HOME/.claude/commit-cost-total.txt}"
mkdir -p "$(dirname "$STATE")" 2>/dev/null || true

# Lifetime cumulative cost across all agents/days — monotonic, so deltas are
# safe across midnight and across sessions.
current=$("$CCUSAGE" daily --json 2>/dev/null | jq -r '.totals.totalCost // 0')
case "$current" in
  ''|*[!0-9.]*) exit 0 ;;   # not a clean number → do nothing
esac

if [ -f "$STATE" ]; then
  last=$(head -n1 "$STATE" 2>/dev/null || echo "$current")
  case "$last" in ''|*[!0-9.]*) last="$current" ;; esac
else
  last="$current"   # first commit after install: baseline, delta = 0
fi

delta=$(awk -v c="$current" -v l="$last" \
  'BEGIN { d = c - l; if (d < 0) d = 0; printf "%.2f", d }')

# Advance the baseline.
printf '%s\n' "$current" > "$STATE"

# Append once. Guard against duplicates on --amend / re-runs.
if ! grep -q '^AI-cost:' "$MSG_FILE" 2>/dev/null; then
  printf '\nAI-cost: $%s (since last commit)\n' "$delta" >> "$MSG_FILE"
fi

exit 0
