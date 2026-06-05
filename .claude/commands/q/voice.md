---
name: q:voice
description: Toggle voice (TTS) on or off, or stop current playback
triggers: [voice, tts, speak, mute, unmute]
argument-hint: "[on|off|stop|status] (default: toggle)"
allowed-tools: [Bash, Read]
autonomy: auto
namespace: dx
---

## Objective
Control voice (text-to-speech) playback for Claude responses.

## Process

1. Read the argument: `$ARGUMENTS`
   - `on` — enable voice
   - `off` — disable voice and stop any current playback
   - `stop` — stop current playback without changing the setting
   - `status` — show current voice state
   - empty/`toggle` — flip the current state

2. Run the voice control script:
   ```bash
   bash /Users/muhammadqureshi/Documents/Projects/agent-q-framework/tools/voice.sh $ARGUMENTS
   ```

3. Report the result to the user in one line.
