#!/bin/bash
# Toggle or control voice (TTS) in Claude Code
# Usage:
#   voice.sh          → toggle on/off
#   voice.sh on       → enable
#   voice.sh off      → disable
#   voice.sh stop     → stop current playback
#   voice.sh status   → show current state

SETTINGS="$HOME/.claude/settings.json"

get_state() {
  jq -r '.voiceEnabled // false' "$SETTINGS" 2>/dev/null
}

set_state() {
  local val="$1"
  local tmp=$(mktemp)
  jq --argjson v "$val" '.voiceEnabled = $v' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
}

case "${1:-toggle}" in
  on)
    set_state true
    echo "Voice enabled"
    ;;
  off)
    pkill -f afplay 2>/dev/null
    set_state false
    echo "Voice disabled"
    ;;
  stop)
    pkill -f afplay 2>/dev/null
    echo "Playback stopped"
    ;;
  status)
    state=$(get_state)
    playing=""
    pgrep -f afplay >/dev/null 2>&1 && playing=" (playing)"
    echo "Voice: $state$playing"
    ;;
  toggle|"")
    current=$(get_state)
    if [ "$current" = "true" ]; then
      pkill -f afplay 2>/dev/null
      set_state false
      echo "Voice disabled"
    else
      set_state true
      echo "Voice enabled"
    fi
    ;;
  *)
    echo "Usage: voice.sh [on|off|stop|status|toggle]"
    exit 1
    ;;
esac
