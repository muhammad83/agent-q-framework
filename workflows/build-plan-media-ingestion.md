# Build Plan D: Media Ingestion (/q:ingest)

## Goal
Add a `/q:ingest` command that extracts transcripts + keyframes from YouTube, social media videos, and local media files, making them available as Agent Q context.

## Discovery Level
Level 1 — Tools are well-known (yt-dlp, ffmpeg, whisper). No architectural uncertainty.

## Tasks

### Task 1: Build `tools/ingest.sh`
Create the ingestion script with three modes:

```bash
./tools/ingest.sh <url>              # YouTube / social media
./tools/ingest.sh <local-file>       # Local video/audio
./tools/ingest.sh --batch urls.txt   # Multiple URLs
```

**Processing pipeline:**

1. **Dependency check** — verify yt-dlp, ffmpeg installed. Warn if whisper missing.
2. **Input detection** — URL vs local file vs --batch flag
3. **For URLs:**
   - `yt-dlp --write-auto-sub --sub-lang en --skip-download` for transcript
   - `yt-dlp -f bestaudio -x` + `whisper` as fallback if no subs
   - `yt-dlp` for metadata (title, duration, description, uploader)
   - Download video, extract keyframes with ffmpeg scene detection
4. **For local files:**
   - Detect audio-only vs video (ffprobe)
   - If video: extract keyframes with `ffmpeg -vf "select=gt(scene,0.3)" -vsync vfr`
   - Transcribe with whisper (M2/M5 GPU via Metal)
5. **Output** to `shared_context/ingested/{video-id-or-filename}/`:
   - `transcript.md` — full transcript with timestamps
   - `metadata.md` — title, source, duration, description, ingestion date
   - `keyframes/` — frame_001.png through frame_020.png (max 20)
   - `summary.md` — combined markdown file for Agent Q to read

**Summary.md format:**
```markdown
# [Video Title]
- Source: [url or filepath]
- Duration: [HH:MM:SS]
- Ingested: [date]
- Type: [youtube|social|local-video|local-audio]

## Transcript
[full transcript with timestamps]

## Keyframes
![Frame 1](keyframes/frame_001.png)
[...up to 20]

## Metadata
[description, tags, channel/uploader info]
```

**Flags:**
- `--no-keyframes` — skip keyframe extraction (faster, transcript only)
- `--force` — re-ingest even if output already exists
- `--summary-only` — for long videos (2h+), truncate transcript to first/last 5 min + chapter markers

**Edge case handling:**
- No subtitles → whisper fallback
- Age-restricted → prompt for `--cookies browser` flag
- Unsupported site → error with suggestion to download manually
- Audio-only file → skip keyframes
- Duplicate → skip unless `--force`
- Too many keyframes → cap at 20, increase scene threshold
- Long video (2h+) → warn, suggest `--summary-only`

### Task 2: Build `/q:ingest` Command + Update Docs
Create `.claude/commands/q/ingest.md`:

```yaml
---
name: q:ingest
description: Ingest video/audio content for Agent Q context
triggers: [ingest, video, youtube, media, transcript, podcast]
argument-hint: "[URL or local file path]"
allowed-tools: [Read, Bash, Glob, Grep]
autonomy: confirm
namespace: dx
---
```

Command process:
1. Run `./tools/ingest.sh $ARGUMENTS`
2. Read the generated summary.md
3. Report what was ingested and where it's stored
4. Remind user they can reference it with: "check shared_context/ingested/{id}/summary.md"

**Update SKILL.md:**
- Add `/q:ingest` to command table
- Add `shared_context/ingested/` to Resources table

**Update CLAUDE.md:**
- Add `shared_context/ingested/` to on-demand loading section

**Create directory:**
- `shared_context/ingested/.gitkeep`

## Files

| Action | File |
|--------|------|
| Create | `tools/ingest.sh` |
| Create | `.claude/commands/q/ingest.md` |
| Create | `shared_context/ingested/.gitkeep` |
| Modify | `SKILL.md` — add command + resource |
| Modify | `CLAUDE.md` — add on-demand loading entry |

## Dependencies
- `yt-dlp` — `brew install yt-dlp` (required)
- `ffmpeg` — `brew install ffmpeg` (required)
- `openai-whisper` — `pip install openai-whisper` (optional, fallback)

No API keys. No env vars. All local processing. M2/M5 GPU accelerates whisper via Metal.

## Verification
1. `./tools/ingest.sh https://youtube.com/watch?v=<short-video>` — transcript + keyframes
2. `./tools/ingest.sh sample.mp3` — transcript only, no keyframes
3. Missing dependency — clear error with install command
4. Duplicate URL — skips with message
5. `/q:ingest <url>` in Claude Code — calls script, reads output
6. SKILL.md and CLAUDE.md updated correctly

## Rollback
Delete `tools/ingest.sh`, `.claude/commands/q/ingest.md`, `shared_context/ingested/`.
Remove added lines from SKILL.md and CLAUDE.md.
