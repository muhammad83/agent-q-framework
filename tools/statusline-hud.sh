#!/bin/bash
set -f

input=$(cat)

if [ -z "$input" ]; then
    printf "Q"
    exit 0
fi

# ── RGB Colors (rich palette) ───────────────────────────
blue='\033[38;2;0;153;255m'
green='\033[38;2;0;175;80m'
cyan='\033[38;2;86;182;194m'
red='\033[38;2;255;85;85m'
orange='\033[38;2;255;176;85m'
yellow='\033[38;2;230;200;0m'
white='\033[38;2;220;220;220m'
dim='\033[2m'
reset='\033[0m'

sep=" ${dim}│${reset} "

# ── Helpers ─────────────────────────────────────────────
format_tokens() {
    local num=$1
    if [ "$num" -ge 1000000 ]; then
        awk "BEGIN {printf \"%.1fm\", $num / 1000000}"
    elif [ "$num" -ge 1000 ]; then
        awk "BEGIN {printf \"%.0fk\", $num / 1000}"
    else
        printf "%d" "$num"
    fi
}

color_for_pct() {
    local pct=$1
    if [ "$pct" -ge 90 ]; then printf "$red"
    elif [ "$pct" -ge 70 ]; then printf "$yellow"
    elif [ "$pct" -ge 50 ]; then printf "$orange"
    else printf "$green"
    fi
}

build_bar() {
    local pct=$1
    local width=$2
    [ "$pct" -lt 0 ] 2>/dev/null && pct=0
    [ "$pct" -gt 100 ] 2>/dev/null && pct=100

    local filled=$(( pct * width / 100 ))
    local empty=$(( width - filled ))
    local bar_color
    bar_color=$(color_for_pct "$pct")

    local filled_str="" empty_str=""
    for ((i=0; i<filled; i++)); do filled_str+="●"; done
    for ((i=0; i<empty; i++)); do empty_str+="○"; done

    printf "${bar_color}${filled_str}${dim}${empty_str}${reset}"
}

format_reset_time() {
    local epoch=$1
    [ -z "$epoch" ] || [ "$epoch" = "null" ] && return

    # Always show: Day Mon Date, Time  (e.g., "Thu Mar 27, 6:05pm")
    local result=""
    result=$(date -r "$epoch" +"%a %b %-d, %l:%M%p" 2>/dev/null | sed 's/  / /g; s/^ //')
    [ -z "$result" ] && result=$(date -d "@$epoch" +"%a %b %-d, %l:%M%P" 2>/dev/null | sed 's/  / /g; s/^ //')

    # Clean up am/pm: remove dots, lowercase
    result=$(echo "$result" | sed 's/A\.M\./am/g; s/P\.M\./pm/g; s/a\.m\./am/g; s/p\.m\./pm/g; s/AM/am/g; s/PM/pm/g')

    printf "%s" "$result"
}

format_duration() {
    local ms=$1 s=$(( $1 / 1000 ))
    local h=$(( s / 3600 )) m=$(( (s % 3600) / 60 ))
    if [ "$h" -gt 0 ]; then printf '%dh%dm' "$h" "$m"
    elif [ "$m" -gt 0 ]; then printf '%dm' "$m"
    else printf '%ds' "$s"; fi
}

# ── Extract JSON ────────────────────────────────────────
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')
model_id=$(echo "$input" | jq -r '.model.id // ""')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
[ -z "$cwd" ] || [ "$cwd" = "null" ] && cwd=$(pwd)
dirname=$(basename "$cwd")

ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | awk '{printf "%.0f", $1}')
total_in=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
win_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')

cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

rl_5h_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' | awk '{printf "%.0f", $1}')
rl_5h_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
rl_7d_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' | awk '{printf "%.0f", $1}')
rl_7d_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Git
git_branch=""
git_dirty=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
    if [ -n "$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
        git_dirty="*"
    fi
fi

# ── Derive mode & thinking ─────────────────────────────
# Thinking: inferred from model ID containing "thinking" or extended context hints
thinking=""
case "$model_id" in
    *thinking*) thinking="thinking" ;;
esac

# Mode badge: fast, plan, or default (no badge)
mode_badge=""
case "$output_style" in
    fast)    mode_badge="${orange}fast${reset}" ;;
    plan)    mode_badge="${yellow}plan${reset}" ;;
esac

# ── LINE 1: model │ mode │ $cost │ dir (branch) │ session ──
line1="${blue}${model_name}${reset}"

# Append thinking + mode tags
if [ -n "$thinking" ]; then
    line1+=" ${dim}(${thinking})${reset}"
fi
if [ -n "$mode_badge" ]; then
    line1+="${sep}${mode_badge}"
fi

if [ -n "$cost" ]; then
    cost_fmt=$(printf '%.2f' "$cost")
    line1+="${sep}${green}\$${cost_fmt}${reset}"
fi

line1+="${sep}${cyan}${dirname}${reset}"
if [ -n "$git_branch" ]; then
    line1+=" ${green}(${git_branch}${red}${git_dirty}${green})${reset}"
fi

if [ -n "$duration_ms" ] && [ "$duration_ms" != "null" ]; then
    dur=$(format_duration "$duration_ms")
    line1+="${sep}${dim}session${reset} ${white}${dur}${reset}"
fi

# Voice indicator
voice_on=$(jq -r '.voiceEnabled // false' "$HOME/.claude/settings.json" 2>/dev/null)
if [ "$voice_on" = "true" ]; then
    playing=""
    pgrep -f afplay >/dev/null 2>&1 && playing=" ${dim}playing${reset}"
    line1+="${sep}${green}voice on${reset}${playing}"
else
    line1+="${sep}${dim}voice off${reset}"
fi

# ── LINE 2: context bar ────────────────────────────────
pct_color=$(color_for_pct "$ctx_pct")
in_fmt=$(format_tokens "$total_in")
out_fmt=$(format_tokens "$total_out")
win_fmt=$(format_tokens "$win_size")

ctx_bar=$(build_bar "$ctx_pct" 20)
line2="${white}context${reset} ${ctx_bar} ${pct_color}$(printf '%3d' "$ctx_pct")%${reset}  ${dim}${in_fmt} in · ${out_fmt} out · ${win_fmt} window${reset}"

# ── LINE 3: rate limit (5hr) ───────────────────────────
rate_lines=""
if [ -n "$rl_5h_pct" ] && [ "$rl_5h_pct" != "0" -o -n "$rl_5h_reset" ]; then
    rl5_bar=$(build_bar "$rl_5h_pct" 10)
    rl5_color=$(color_for_pct "$rl_5h_pct")
    rl5_reset_fmt=$(format_reset_time "$rl_5h_reset")
    rate_lines="${white}current${reset} ${rl5_bar} ${rl5_color}$(printf '%3d' "$rl_5h_pct")%${reset}"
    [ -n "$rl5_reset_fmt" ] && rate_lines+=" ${dim}⟳${reset} ${white}${rl5_reset_fmt}${reset}"
fi

# ── LINE 4: rate limit (7day) ──────────────────────────
if [ -n "$rl_7d_pct" ] && [ "$rl_7d_pct" != "0" -o -n "$rl_7d_reset" ]; then
    rl7_bar=$(build_bar "$rl_7d_pct" 10)
    rl7_color=$(color_for_pct "$rl_7d_pct")
    rl7_reset_fmt=$(format_reset_time "$rl_7d_reset")
    rl7_line="${white}weekly${reset}  ${rl7_bar} ${rl7_color}$(printf '%3d' "$rl_7d_pct")%${reset}"
    [ -n "$rl7_reset_fmt" ] && rl7_line+=" ${dim}⟳${reset} ${white}${rl7_reset_fmt}${reset}"
    if [ -n "$rate_lines" ]; then
        rate_lines+="\n${rl7_line}"
    else
        rate_lines="${rl7_line}"
    fi
fi

# ── LINE 5: changes ────────────────────────────────────
changes_line=""
if [ "$lines_added" -gt 0 ] || [ "$lines_removed" -gt 0 ]; then
    changes_line="${white}changes${reset} ${green}+${lines_added} added${reset} ${dim}·${reset} ${red}-${lines_removed} removed${reset}"
fi

# ── LINE 6: ccusage token analyzer (today · burn · block) ──
# Non-blocking: read a short-lived cache instantly; refresh it in the
# background when stale so the HUD never waits on ccusage.
usage_line=""
CCUSAGE_BIN=""
if [ -x "$HOME/.bun/bin/ccusage" ]; then CCUSAGE_BIN="$HOME/.bun/bin/ccusage"
elif command -v ccusage >/dev/null 2>&1; then CCUSAGE_BIN="ccusage"; fi

if [ -n "$CCUSAGE_BIN" ]; then
    cache_file="/tmp/ccusage-hud-$(id -u).cache"

    # Determine staleness (refresh every 45s)
    stale=1
    if [ -f "$cache_file" ]; then
        mtime=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null)
        now=$(date +%s)
        [ -n "$mtime" ] && [ $(( now - mtime )) -lt 45 ] && stale=0
    fi

    # Kick a background refresh; this render still uses whatever's cached.
    if [ "$stale" = "1" ]; then
        (
            today=$("$CCUSAGE_BIN" daily --json 2>/dev/null | jq -r '.daily[-1].totalCost // 0')
            bj=$("$CCUSAGE_BIN" blocks --active --json 2>/dev/null)
            bc=$(echo "$bj" | jq -r '.blocks[0].costUSD // 0')
            br=$(echo "$bj" | jq -r '.blocks[0].burnRate.costPerHour // 0')
            rm_=$(echo "$bj" | jq -r '.blocks[0].projection.remainingMinutes // 0')
            printf '%s|%s|%s|%s' "$today" "$bc" "$br" "$rm_" > "$cache_file.tmp" 2>/dev/null \
                && mv "$cache_file.tmp" "$cache_file" 2>/dev/null
        ) >/dev/null 2>&1 &
        disown 2>/dev/null
    fi

    if [ -f "$cache_file" ]; then
        IFS='|' read -r u_today u_block u_burn u_remain < "$cache_file"
        if [ -n "$u_today" ] && [ "$u_today" != "0" ] && [ "$u_today" != "null" ]; then
            today_fmt=$(printf '%.2f' "$u_today" 2>/dev/null)
            burn_fmt=$(printf '%.2f' "$u_burn" 2>/dev/null)
            usage_line="${white}usage${reset}   ${green}\$${today_fmt} today${reset}"
            if [ -n "$u_burn" ] && [ "$u_burn" != "0" ] && [ "$u_burn" != "null" ]; then
                usage_line+=" ${dim}·${reset} ${orange}\$${burn_fmt}/hr burn${reset}"
            fi
            rem_int=${u_remain%.*}
            if [ -n "$rem_int" ] && [ "$rem_int" != "0" ] && [ "$rem_int" != "null" ] 2>/dev/null; then
                rem_h=$(( rem_int / 60 )); rem_m=$(( rem_int % 60 ))
                if [ "$rem_h" -gt 0 ]; then rem_fmt="${rem_h}h${rem_m}m"; else rem_fmt="${rem_m}m"; fi
                usage_line+=" ${dim}·${reset} ${dim}block ${rem_fmt} left${reset}"
            fi
        fi
    fi
fi

# ── Output ──────────────────────────────────────────────
printf "%b" "$line1"
printf "\n\n%b" "$line2"
[ -n "$rate_lines" ] && printf "\n%b" "$rate_lines"
[ -n "$changes_line" ] && printf "\n%b" "$changes_line"
[ -n "$usage_line" ] && printf "\n%b" "$usage_line"

exit 0
