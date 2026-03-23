#!/usr/bin/env bash
# hooks/session-start.sh — Platform detection and context injection for Agent Q
#
# Detects which AI coding platform is running and outputs the appropriate
# context injection format. Falls back to Claude Code format if unknown.
#
# Usage: source hooks/session-start.sh
#        or: bash hooks/session-start.sh

set -euo pipefail

# detect_platform — returns the platform name based on env vars and process names
detect_platform() {
  # Check environment variables first (fastest, most reliable)

  if [ -n "${CLAUDE_CODE:-}" ]; then
    echo "claude-code"
    return 0
  fi

  if [ -n "${CURSOR_SESSION:-}" ]; then
    echo "cursor"
    return 0
  fi

  if [ -n "${CODEX_SESSION:-}" ]; then
    echo "codex"
    return 0
  fi

  if [ -n "${OPENCODE_SESSION:-}" ]; then
    echo "opencode"
    return 0
  fi

  if [ -n "${GEMINI_CLI:-}" ]; then
    echo "gemini-cli"
    return 0
  fi

  # Fall back to process name detection (slower, less reliable)

  if pgrep -f "cursor" > /dev/null 2>&1; then
    echo "cursor"
    return 0
  fi

  if pgrep -f "codex" > /dev/null 2>&1; then
    echo "codex"
    return 0
  fi

  # Default: Claude Code (most capable, safest fallback)
  echo "claude-code"
  return 0
}

# inject_context — outputs platform-appropriate context loading instructions
inject_context() {
  local platform="$1"
  local project_root
  project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

  case "$platform" in
    claude-code)
      # Claude Code reads CLAUDE.md as entry point
      echo "PLATFORM=claude-code"
      echo "ENTRY_POINT=${project_root}/CLAUDE.md"
      echo "COMMANDS_DIR=${project_root}/.claude/commands/q"
      echo "HOOKS_DIR=${project_root}/hooks"
      ;;
    cursor)
      # Cursor uses .cursor-plugin/plugin.json for skill discovery
      echo "PLATFORM=cursor"
      echo "ENTRY_POINT=${project_root}/.cursor-plugin/plugin.json"
      echo "COMMANDS_DIR=${project_root}/.claude/commands/q"
      echo "HOOKS_DIR=${project_root}/hooks"
      ;;
    codex)
      # Codex uses agent.md as entry point with symlink-based discovery
      echo "PLATFORM=codex"
      echo "ENTRY_POINT=${project_root}/agent.md"
      echo "COMMANDS_DIR=${project_root}/.claude/commands/q"
      echo "HOOKS_DIR=${project_root}/hooks"
      ;;
    opencode)
      # OpenCode uses .opencode/config.json for hook registration
      echo "PLATFORM=opencode"
      echo "ENTRY_POINT=${project_root}/.opencode/config.json"
      echo "COMMANDS_DIR=${project_root}/.claude/commands/q"
      echo "HOOKS_DIR=${project_root}/hooks"
      ;;
    gemini-cli)
      # Gemini CLI uses native extension format
      # Note: no subagent support — /q:orchestrate and /q:spinjitsu fall back to inline
      echo "PLATFORM=gemini-cli"
      echo "ENTRY_POINT=${project_root}/agents/gemini-cli-extension.md"
      echo "COMMANDS_DIR=${project_root}/.claude/commands/q"
      echo "HOOKS_DIR=${project_root}/hooks"
      echo "LIMITATION=no-subagent"
      ;;
    *)
      # Unknown platform — fall back to Claude Code format
      echo "PLATFORM=claude-code"
      echo "ENTRY_POINT=${project_root}/CLAUDE.md"
      echo "COMMANDS_DIR=${project_root}/.claude/commands/q"
      echo "HOOKS_DIR=${project_root}/hooks"
      ;;
  esac
}

# Main execution
main() {
  local platform
  platform="$(detect_platform)"

  echo "# Agent Q — Session Start"
  echo "# Detected platform: ${platform}"
  echo "#"

  inject_context "$platform"
}

# Run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
