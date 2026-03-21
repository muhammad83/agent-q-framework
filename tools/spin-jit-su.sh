#!/bin/bash

# Agent Q Framework — Spin Jit Su Launcher
# Kicks off parallel Claude Code instances across worktrees or plan files.
#
# Usage:
#   ./tools/spin-jit-su.sh                           # Auto-detect: all build-plan-*.md files
#   ./tools/spin-jit-su.sh plan1.md plan2.md          # Specific plans
#   ./tools/spin-jit-su.sh --worktrees dir1 dir2      # Separate directories
#
# Requirements:
#   - tmux installed (brew install tmux)
#   - claude CLI installed
#
# What it does:
#   1. Creates a tmux session called "spinjitsu"
#   2. Opens one window per plan/worktree
#   3. Launches Claude with auto-accept in each
#   4. Sends the build prompt automatically
#   5. You just rotate between windows (Ctrl+B then number)

set -e

# Unset CLAUDECODE to allow launching from inside an existing Claude session.
# Without this, Claude Code blocks "nested sessions" and refuses to start.
unset CLAUDECODE

SESSION="spinjitsu"
MODEL="${SPINJITSU_MODEL:-}"  # Optional: override model (e.g. claude-sonnet-4-6)
CLAUDE_CMD="claude --dangerously-skip-permissions"

if [ -n "$MODEL" ]; then
    CLAUDE_CMD="claude --model $MODEL --dangerously-skip-permissions"
fi

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo -e "  Agent Q — Spin Jit Su Launcher"
echo -e "==========================================${NC}"
echo ""

# Kill existing session if running
if tmux has-session -t "$SESSION" 2>/dev/null; then
    echo -e "${YELLOW}⚠ Existing spinjitsu session found.${NC}"
    read -p "Kill it and start fresh? (y/n): " KILL
    if [ "$KILL" = "y" ] || [ "$KILL" = "Y" ]; then
        tmux kill-session -t "$SESSION"
        echo "  Killed existing session."
    else
        echo "  Attaching to existing session..."
        tmux attach -t "$SESSION"
        exit 0
    fi
fi

# Determine mode
PLANS=()
DIRS=()
WORKTREE_MODE=false

if [ "$1" = "--worktrees" ]; then
    WORKTREE_MODE=true
    shift
    DIRS=("$@")
    if [ ${#DIRS[@]} -lt 2 ]; then
        echo "Error: --worktrees requires at least 2 directories"
        exit 1
    fi
elif [ $# -gt 0 ]; then
    # Specific plan files passed
    for f in "$@"; do
        if [ -f "$f" ]; then
            PLANS+=("$f")
        else
            echo "Error: Plan file not found: $f"
            exit 1
        fi
    done
else
    # Auto-detect: find all build-plan-*.md in workflows/
    if [ -d "workflows" ]; then
        for f in workflows/build-plan-*.md; do
            [ -f "$f" ] && PLANS+=("$f")
        done
    fi
    if [ ${#PLANS[@]} -lt 2 ]; then
        echo "Error: Need at least 2 build plans in workflows/"
        echo "Found: ${PLANS[*]:-none}"
        echo ""
        echo "Usage:"
        echo "  $0                              # Auto-detect plans in workflows/"
        echo "  $0 workflows/plan-a.md workflows/plan-b.md"
        echo "  $0 --worktrees /path/a /path/b"
        exit 1
    fi
fi

# Show what we're launching
if [ "$WORKTREE_MODE" = true ]; then
    echo -e "Mode: ${GREEN}Worktrees${NC} (separate directories)"
    echo "Instances: ${#DIRS[@]}"
    for d in "${DIRS[@]}"; do
        echo "  → $d"
    done
else
    echo -e "Mode: ${GREEN}Plan files${NC} (same project, parallel features)"
    echo "Instances: ${#PLANS[@]}"
    for p in "${PLANS[@]}"; do
        echo "  → $p"
    done
fi

echo ""
if [ -n "$MODEL" ]; then
    echo -e "Model: ${GREEN}$MODEL${NC}"
else
    echo -e "Model: ${GREEN}default (Sonnet)${NC}  [set SPINJITSU_MODEL to override]"
fi
echo ""
read -p "Launch? (y/n): " GO
if [ "$GO" != "y" ] && [ "$GO" != "Y" ]; then
    echo "Cancelled."
    exit 0
fi

# Create tmux session
echo ""
echo "Creating tmux session: $SESSION"

if [ "$WORKTREE_MODE" = true ]; then
    # First window
    DIR="${DIRS[0]}"
    NAME=$(basename "$DIR")
    tmux new-session -d -s "$SESSION" -n "$NAME" -c "$DIR"
    tmux send-keys -t "$SESSION:$NAME" "export AGENTQ_INSTANCE_ID=\"stream-0\" && unset CLAUDECODE && $CLAUDE_CMD" C-m
    sleep 2
    tmux send-keys -t "$SESSION:$NAME" "Read CLAUDE.md and todo.md. Then read the current build plan in workflows/ and execute it fully. Update todo.md as you go." C-m
    echo -e "  ${GREEN}✓${NC} Window 0: $NAME → $DIR"

    # Remaining windows
    for i in $(seq 1 $((${#DIRS[@]} - 1))); do
        DIR="${DIRS[$i]}"
        NAME=$(basename "$DIR")
        tmux new-window -t "$SESSION" -n "$NAME" -c "$DIR"
        tmux send-keys -t "$SESSION:$NAME" "export AGENTQ_INSTANCE_ID=\"stream-${i}\" && unset CLAUDECODE && $CLAUDE_CMD" C-m
        sleep 2
        tmux send-keys -t "$SESSION:$NAME" "Read CLAUDE.md and todo.md. Then read the current build plan in workflows/ and execute it fully. Update todo.md as you go." C-m
        echo -e "  ${GREEN}✓${NC} Window $i: $NAME → $DIR"
    done
else
    # Plan file mode — all in same directory
    PROJECT_DIR="$(pwd)"
    PLAN="${PLANS[0]}"
    NAME=$(basename "$PLAN" .md | sed 's/build-plan-//')
    tmux new-session -d -s "$SESSION" -n "$NAME" -c "$PROJECT_DIR"
    tmux send-keys -t "$SESSION:$NAME" "export AGENTQ_INSTANCE_ID=\"stream-0\" && unset CLAUDECODE && $CLAUDE_CMD" C-m
    sleep 2
    tmux send-keys -t "$SESSION:$NAME" "Read $PLAN and execute it fully. Update todo.md as you go." C-m
    echo -e "  ${GREEN}✓${NC} Window 0: $NAME → $PLAN"

    for i in $(seq 1 $((${#PLANS[@]} - 1))); do
        PLAN="${PLANS[$i]}"
        NAME=$(basename "$PLAN" .md | sed 's/build-plan-//')
        tmux new-window -t "$SESSION" -n "$NAME" -c "$PROJECT_DIR"
        tmux send-keys -t "$SESSION:$NAME" "export AGENTQ_INSTANCE_ID=\"stream-${i}\" && unset CLAUDECODE && $CLAUDE_CMD" C-m
        sleep 2
        tmux send-keys -t "$SESSION:$NAME" "Read $PLAN and execute it fully. Update todo.md as you go." C-m
        echo -e "  ${GREEN}✓${NC} Window $i: $NAME → $PLAN"
    done
fi

echo ""
echo -e "${GREEN}=========================================="
echo -e "  All instances launched!"
echo -e "==========================================${NC}"
echo ""
echo "  tmux controls:"
echo "    Ctrl+B then 0-9  → switch window"
echo "    Ctrl+B then n/p  → next/prev window"
echo "    Ctrl+B then d    → detach (keeps running)"
echo "    tmux attach -t $SESSION  → reattach"
echo ""
echo "  Rotate every 5-10 min. Steer if stuck. Let them cook if not."
echo ""

# Attach
tmux attach -t "$SESSION"
