---
name: q:ingest
description: Ingest video/audio content for Agent Q context
triggers: [ingest, video, youtube, media, transcript, podcast]
argument-hint: "[URL or local file path]"
allowed-tools: [Read, Bash, Glob, Grep]
autonomy: confirm
namespace: dx
---

## Objective
Ingest video or audio content and make it available as Agent Q context.
Supports YouTube, social media (1000+ sites via yt-dlp), and local files.

## Input
URL or file path: $ARGUMENTS

## Process

1. **Run ingestion.** Execute `./tools/ingest.sh $ARGUMENTS`
2. **Check output.** Read the generated summary.md from `shared_context/ingested/{id}/summary.md`
3. **Report results.** Tell the user:
   - What was ingested (title, duration, type)
   - Where it's stored
   - How many keyframes were extracted
   - Whether transcript came from subtitles or whisper
4. **Remind user.** They can reference this content later:
   "Read shared_context/ingested/{id}/summary.md for context from [title]"

## Flags
Pass through to ingest.sh:
- `--no-keyframes` — skip keyframe extraction (faster)
- `--force` — re-ingest even if already done
- `--summary-only` — truncate long transcripts
- `--batch <file>` — process multiple URLs from a file

## Dependencies
- Required: `yt-dlp` (`brew install yt-dlp`), `ffmpeg` (`brew install ffmpeg`)
- Optional: `openai-whisper` (`pip install openai-whisper`) — fallback transcription
