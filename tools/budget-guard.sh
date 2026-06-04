#!/usr/bin/env bash
# budget-guard.sh — workday spend pacer for a fixed daily AI budget.
#
# Answers: "at this rate, will I run out before the workday ends?" It compares
# today's cumulative spend (from ccusage) against a daily budget AND the fraction
# of the workday elapsed, so being at 50% budget at noon (half a 8→20 day) is
# ON-TRACK, but 50% by 10am is OVER pace.
#
# Modes:
#   budget-guard.sh                 human-readable report (calls ccusage)
#   budget-guard.sh --json          same data as JSON (calls ccusage)
#   budget-guard.sh --pace <spent>  pure pace math for a given $ spent (NO ccusage
#                                   call) → pipe-delimited fields for the statusline:
#                                   budget_pct|status_key|projected_eod|remaining|expected
#
# Config (env or .env defaults — all overridable, nothing hardcoded in logic):
#   Q_DAILY_BUDGET_USD  (40)   daily budget in dollars
#   Q_WORKDAY_START     (8)    workday start hour, 0-23
#   Q_WORKDAY_END       (20)   workday end hour, 0-23
#
# Degrades silently if ccusage/jq/awk are missing — never blocks anything.

set -uo pipefail

# ── Config ──────────────────────────────────────────────
BUDGET="${Q_DAILY_BUDGET_USD:-40}"
START_H="${Q_WORKDAY_START:-8}"
END_H="${Q_WORKDAY_END:-20}"

# ── ANSI (matches the HUD palette) ──────────────────────
green='\033[38;2;0;175;80m'
cyan='\033[38;2;86;182;194m'
red='\033[38;2;255;85;85m'
orange='\033[38;2;255;176;85m'
white='\033[38;2;220;220;220m'
dim='\033[2m'
reset='\033[0m'

command -v awk >/dev/null 2>&1 || exit 0

# ── Pace math (pure) ────────────────────────────────────
# Args: spent_usd → echoes "budget_pct|status_key|projected_eod|remaining|expected"
# status_key ∈ preday | under | ontrack | over | critical | postday
compute_pace() {
    local spent="$1"
    awk -v spent="$spent" -v budget="$BUDGET" -v sh="$START_H" -v eh="$END_H" '
    BEGIN {
        # current time as fractional hour (local)
        "date +%H" | getline H; "date +%M" | getline M
        now = H + M/60.0
        span = eh - sh
        if (span <= 0) span = 12

        spent_frac = (budget > 0) ? spent / budget : 0
        remaining  = budget - spent
        if (remaining < 0) remaining = 0

        if (now < sh) {
            time_frac = 0
        } else if (now >= eh) {
            time_frac = 1
        } else {
            time_frac = (now - sh) / span
        }
        expected = time_frac * budget

        # projected end-of-day spend at the rate implied so far today
        if (time_frac > 0.01) proj = spent / time_frac
        else proj = spent

        # status
        if (now < sh)            key = "preday"
        else if (now >= eh)      key = "postday"
        else {
            ratio = (time_frac > 0) ? spent_frac / time_frac : 999
            if (proj > budget * 1.25 || spent >= budget) key = "critical"
            else if (ratio > 1.10)  key = "over"
            else if (ratio < 0.90)  key = "under"
            else                    key = "ontrack"
        }

        budget_pct = (budget > 0) ? spent_frac * 100 : 0
        printf "%.0f|%s|%.2f|%.2f|%.2f", budget_pct, key, proj, remaining, expected
    }'
}

color_for_key() {
    case "$1" in
        under)            printf '%b' "$green" ;;
        ontrack)          printf '%b' "$cyan" ;;
        over)             printf '%b' "$orange" ;;
        critical)         printf '%b' "$red" ;;
        *)                printf '%b' "$dim" ;;
    esac
}

label_for_key() {
    case "$1" in
        preday)   echo "before workday" ;;
        postday)  echo "after workday" ;;
        under)    echo "under pace" ;;
        ontrack)  echo "on track" ;;
        over)     echo "over pace" ;;
        critical) echo "OVER BUDGET RISK" ;;
        *)        echo "$1" ;;
    esac
}

# ── --pace mode: pure math, no ccusage (used by statusline) ──
if [ "${1:-}" = "--pace" ]; then
    spent="${2:-0}"
    case "$spent" in ''|*[!0-9.]*) spent=0 ;; esac
    compute_pace "$spent"
    exit 0
fi

# ── Modes that need today's spend: locate ccusage ───────
CCUSAGE=""
if command -v ccusage >/dev/null 2>&1; then CCUSAGE="ccusage"
elif [ -x "$HOME/.bun/bin/ccusage" ]; then CCUSAGE="$HOME/.bun/bin/ccusage"; fi
command -v jq >/dev/null 2>&1 || { [ "${1:-}" = "--json" ] && echo '{"error":"jq missing"}'; exit 0; }

spent=0
if [ -n "$CCUSAGE" ]; then
    spent=$("$CCUSAGE" daily --json 2>/dev/null | jq -r '.daily[-1].totalCost // 0')
    case "$spent" in ''|*[!0-9.]*) spent=0 ;; esac
fi

IFS='|' read -r budget_pct key proj remaining expected <<EOF
$(compute_pace "$spent")
EOF

# ── --json output ───────────────────────────────────────
if [ "${1:-}" = "--json" ]; then
    printf '{"spent":%s,"budget":%s,"budget_pct":%s,"status":"%s","projected_eod":%s,"remaining":%s,"expected_by_now":%s,"workday":"%02d:00-%02d:00"}\n' \
        "$spent" "$BUDGET" "$budget_pct" "$key" "$proj" "$remaining" "$expected" "$START_H" "$END_H"
    exit 0
fi

# ── Human-readable report ───────────────────────────────
clr=$(color_for_key "$key")
lbl=$(label_for_key "$key")
spent_fmt=$(printf '%.2f' "$spent")
exp_fmt=$(printf '%.2f' "$expected")
proj_fmt=$(printf '%.2f' "$proj")
rem_fmt=$(printf '%.2f' "$remaining")

printf "%b\n" "${white}Budget Guard${reset}  ${dim}(workday ${START_H}:00–${END_H}:00, \$${BUDGET}/day)${reset}"
printf "%b\n" "  spent today    ${green}\$${spent_fmt}${reset}  ${dim}of \$${BUDGET} (${budget_pct}%)${reset}"
printf "%b\n" "  expected now   ${dim}\$${exp_fmt} at a linear pace${reset}"
printf "%b\n" "  status         ${clr}${lbl}${reset}"
printf "%b\n" "  projected EOD  ${clr}\$${proj_fmt}${reset}  ${dim}at today's rate${reset}"
printf "%b\n" "  remaining      ${white}\$${rem_fmt}${reset}"

if [ -z "$CCUSAGE" ]; then
    printf "%b\n" "  ${dim}(ccusage not found — spend shown as \$0; install: bun add -g ccusage)${reset}"
fi
exit 0
