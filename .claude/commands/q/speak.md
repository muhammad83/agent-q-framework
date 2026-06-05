---
name: q:speak
description: Replay the last TTS audio response
triggers: [speak, replay, repeat]
argument-hint: ""
allowed-tools: [Bash]
autonomy: auto
namespace: dx
---

## Objective
Replay the last text-to-speech audio.

## Process

1. Run: `afplay /tmp/tts-replay.mp3`
2. If the file doesn't exist, tell the user there's no recent audio to replay.
