#!/bin/bash

# Agent Q Framework — Heartbeat Script
# Usage: ./tools/heartbeat.sh [--quiet]
#
# Proactive monitoring for your project. Checks for common issues
# and reports them before they become problems.
#
# Setup:
#   chmod +x tools/heartbeat.sh
#
# Run manually:
#   ./tools/heartbeat.sh
#
# Run via cron (every 6 hours):
#   crontab -e
#   0 */6 * * * cd /path/to/your-project && ./tools/heartbeat.sh --quiet >> logs/heartbeat.log 2>&1

QUIET=false
if [ "$1" = "--quiet" ]; then
  QUIET=true
fi

ISSUES=0

# --- Helper functions ---

warn() {
  echo "⚠️  $1"
  ((ISSUES++))
}

ok() {
  if [ "$QUIET" = false ]; then
    echo "✅ $1"
  fi
}

header() {
  if [ "$QUIET" = false ]; then
    echo ""
    echo "=========================================="
    echo "  Heartbeat — $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=========================================="
    echo ""
  fi
}

footer() {
  if [ "$ISSUES" -gt 0 ]; then
    echo ""
    echo "-----------------------------------"
    echo "⚠️  $ISSUES issue(s) found"
    echo ""
  elif [ "$QUIET" = false ]; then
    echo ""
    echo "-----------------------------------"
    echo "✅ All clear — no issues found"
    echo ""
  fi
}

# --- Start ---

header

# ===========================================
# CHECKS — Uncomment and customize for your project
# ===========================================

# --- General checks ---

# # Check for uncommitted changes
# if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
#   warn "Uncommitted changes in working directory"
# else
#   ok "Working directory clean"
# fi

# # Check last commit age (warn if older than 24 hours)
# LAST_COMMIT=$(git log -1 --format=%ct 2>/dev/null)
# if [ -n "$LAST_COMMIT" ]; then
#   NOW=$(date +%s)
#   AGE=$(( (NOW - LAST_COMMIT) / 3600 ))
#   if [ "$AGE" -gt 24 ]; then
#     warn "Last commit was $AGE hours ago"
#   else
#     ok "Last commit was $AGE hours ago"
#   fi
# fi

# # Check todo.md for overdue items (items marked with a past date)
# if [ -f "todo.md" ]; then
#   TODAY=$(date +%Y-%m-%d)
#   if grep -qE "\[ \].*[0-9]{4}-[0-9]{2}-[0-9]{2}" todo.md; then
#     ok "todo.md has dated items (check manually for overdue)"
#   fi
# fi

# # Check if tests pass
# if [ -f "pytest.ini" ] || [ -f "pyproject.toml" ]; then
#   if ! pytest --tb=no -q 2>/dev/null; then
#     warn "Tests are failing"
#   else
#     ok "Tests passing"
#   fi
# fi

# --- Sales Agent checks ---

# # Check for stale client folders (no activity in 3+ days)
# if [ -d "clients" ]; then
#   for client_dir in clients/*/; do
#     if [ -d "$client_dir" ]; then
#       LATEST=$(find "$client_dir" -type f -newer "$client_dir" -mtime -3 | head -1)
#       if [ -z "$LATEST" ]; then
#         CLIENT_NAME=$(basename "$client_dir")
#         warn "Client '$CLIENT_NAME' has no activity in 3+ days"
#       fi
#     fi
#   done
# fi

# ===========================================
# No checks configured yet.
# Uncomment the checks above or add your own.
# ===========================================
if [ "$QUIET" = false ]; then
  echo "No checks configured yet."
  echo "Edit tools/heartbeat.sh to enable checks for your project."
fi

footer

if [ "$ISSUES" -gt 0 ]; then
  exit 1
else
  exit 0
fi
