#!/usr/bin/env bash
set -euo pipefail

# tools/ingest.sh — Ingest video/audio content for Agent Q context
# Extracts transcripts + keyframes from YouTube, social media, and local files.
# Usage:
#   ./tools/ingest.sh <url>              # YouTube / social media
#   ./tools/ingest.sh <local-file>       # Local video/audio
#   ./tools/ingest.sh --batch urls.txt   # Multiple URLs from file

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Defaults
FORCE=""
NO_KEYFRAMES=""
SUMMARY_ONLY=""
BATCH_FILE=""
INPUT=""
PASSTHROUGH_FLAGS=""

# ---------------------------------------------------------------------------
# Usage
# ---------------------------------------------------------------------------
usage() {
  cat <<'USAGE'
Usage: ingest.sh [OPTIONS] <URL or FILE>

Modes:
  <url>                YouTube / social media URL (1000+ sites via yt-dlp)
  <local-file>         Local video or audio file
  --batch <file>       Read URLs/paths from a file (one per line)

Options:
  --no-keyframes       Skip keyframe extraction (faster)
  --force              Re-ingest even if output already exists
  --summary-only       Truncate long transcripts in summary.md
  --help               Show this help message

Dependencies:
  Required: yt-dlp, ffmpeg
  Optional: whisper (fallback transcription when subtitles unavailable)
USAGE
}

# ---------------------------------------------------------------------------
# Dependency check
# ---------------------------------------------------------------------------
check_deps() {
  local missing=0
  if ! command -v yt-dlp &>/dev/null; then
    echo "ERROR: yt-dlp is not installed."
    echo "  Install: brew install yt-dlp"
    missing=1
  fi
  if ! command -v ffmpeg &>/dev/null; then
    echo "ERROR: ffmpeg is not installed."
    echo "  Install: brew install ffmpeg"
    missing=1
  fi
  if ! command -v whisper &>/dev/null; then
    echo "NOTE: whisper is not installed (optional — used as fallback transcription)."
    echo "  Install: pip install openai-whisper"
  fi
  if [ "$missing" -eq 1 ]; then
    exit 1
  fi
}

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --help|-h)
        usage
        exit 0
        ;;
      --force)
        FORCE=1
        PASSTHROUGH_FLAGS="$PASSTHROUGH_FLAGS --force"
        shift
        ;;
      --no-keyframes)
        NO_KEYFRAMES=1
        PASSTHROUGH_FLAGS="$PASSTHROUGH_FLAGS --no-keyframes"
        shift
        ;;
      --summary-only)
        SUMMARY_ONLY=1
        PASSTHROUGH_FLAGS="$PASSTHROUGH_FLAGS --summary-only"
        shift
        ;;
      --batch)
        shift
        if [ $# -eq 0 ]; then
          echo "ERROR: --batch requires a file argument"
          exit 1
        fi
        BATCH_FILE="$1"
        shift
        ;;
      -*)
        echo "ERROR: Unknown option: $1"
        usage
        exit 1
        ;;
      *)
        INPUT="$1"
        shift
        ;;
    esac
  done
}

# ---------------------------------------------------------------------------
# Auto-enable --summary-only for long videos (> 2 hours)
# ---------------------------------------------------------------------------
auto_summary_check() {
  local duration="$1"
  if [ -n "$duration" ] && [ -z "$SUMMARY_ONLY" ]; then
    # Remove decimal portion for integer comparison
    local int_duration="${duration%.*}"
    if [ -n "$int_duration" ] && [ "$int_duration" -gt 7200 ] 2>/dev/null; then
      echo "NOTE: Video is longer than 2 hours — auto-enabling --summary-only"
      SUMMARY_ONLY=1
    fi
  fi
}

# ---------------------------------------------------------------------------
# Generate summary.md
# ---------------------------------------------------------------------------
generate_summary() {
  local output_dir="$1"
  local input_type="$2"

  {
    cat "$output_dir/metadata.md"
    echo ""
    echo "- Ingested: $(date +%Y-%m-%d)"
    echo "- Type: ${input_type}"
    echo ""
    echo "## Transcript"
    echo ""
    if [ "$SUMMARY_ONLY" = "1" ]; then
      head -50 "$output_dir/transcript.md"
      echo ""
      echo "[... truncated for length — see full transcript in transcript.md ...]"
      echo ""
      tail -50 "$output_dir/transcript.md"
    else
      cat "$output_dir/transcript.md"
    fi
    echo ""
    echo "## Keyframes"
    echo ""
    local has_frames=0
    for frame in "$output_dir/keyframes"/frame_*.png; do
      if [ -f "$frame" ]; then
        echo "![$(basename "$frame")](keyframes/$(basename "$frame"))"
        has_frames=1
      fi
    done
    if [ "$has_frames" -eq 0 ]; then
      echo "No keyframes extracted."
    fi
  } > "$output_dir/summary.md"

  echo "Ingested: $output_dir/summary.md"
}

# ---------------------------------------------------------------------------
# Ingest from URL
# ---------------------------------------------------------------------------
ingest_url() {
  local url="$1"

  # Get video ID (fall back to md5 of URL)
  local video_id
  video_id=$(yt-dlp --get-id "$url" 2>/dev/null || echo "$url" | md5 -q 2>/dev/null || echo "$url" | md5sum 2>/dev/null | cut -c1-12)
  # Trim to a safe slug length
  video_id="${video_id:0:64}"

  local output_dir="$PROJECT_ROOT/shared_context/ingested/${video_id}"

  # Check duplicate
  if [ -d "$output_dir" ] && [ -z "$FORCE" ]; then
    echo "Already ingested: $output_dir (use --force to re-ingest)"
    return 0
  fi

  mkdir -p "$output_dir/keyframes"

  # --- Metadata ---
  echo "Fetching metadata..."
  yt-dlp --dump-json "$url" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(f\"# {d.get('title', 'Unknown')}\")
print(f\"- Source: {d.get('webpage_url', '$url')}\")
print(f\"- Duration: {d.get('duration_string', 'unknown')}\")
print(f\"- Uploader: {d.get('uploader', 'unknown')}\")
print(f\"- Upload Date: {d.get('upload_date', 'unknown')}\")
desc = d.get('description', 'none') or 'none'
print(f\"- Description: {desc[:500]}\")
" > "$output_dir/metadata.md"

  # Check duration for auto-summary
  local duration
  duration=$(yt-dlp --dump-json "$url" 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('duration',''))" 2>/dev/null || echo "")
  auto_summary_check "$duration"

  # --- Transcript ---
  echo "Extracting transcript..."
  yt-dlp --write-auto-sub --sub-lang en --skip-download --sub-format vtt -o "$output_dir/subs" "$url" 2>/dev/null || true

  local sub_file
  sub_file=$(find "$output_dir" -name "*.vtt" -o -name "*.srt" 2>/dev/null | head -1)

  if [ -n "$sub_file" ]; then
    echo "Found subtitles: $sub_file"
    python3 -c "
import re
with open('$sub_file') as f:
    text = f.read()
# Remove VTT header and styling
text = re.sub(r'WEBVTT.*?\n\n', '', text, flags=re.DOTALL)
text = re.sub(r'<[^>]+>', '', text)
# Keep timestamps and text
lines = []
for line in text.strip().split('\n'):
    line = line.strip()
    if line and not line.isdigit():
        lines.append(line)
print('\n'.join(lines))
" > "$output_dir/transcript.md"
  else
    # Fallback: download audio and use whisper
    if command -v whisper &>/dev/null; then
      echo "No subtitles found — falling back to whisper..."
      yt-dlp -f bestaudio -x --audio-format wav -o "$output_dir/audio.%(ext)s" "$url"
      local audio_file
      audio_file=$(find "$output_dir" -name "*.wav" | head -1)
      if [ -n "$audio_file" ]; then
        whisper "$audio_file" --output_format txt --output_dir "$output_dir" --language en
        mv "$output_dir"/*.txt "$output_dir/transcript.md" 2>/dev/null || true
        rm -f "$audio_file"
      else
        echo "WARNING: Audio download failed."
        echo "No transcript available." > "$output_dir/transcript.md"
      fi
    else
      echo "WARNING: No subtitles available and whisper not installed."
      echo "Install with: pip install openai-whisper"
      echo "No transcript available." > "$output_dir/transcript.md"
    fi
  fi

  # --- Keyframes ---
  if [ -z "$NO_KEYFRAMES" ]; then
    echo "Extracting keyframes..."
    yt-dlp -f "bestvideo[height<=720]" -o "$output_dir/video.%(ext)s" "$url" 2>/dev/null || true
    local video_file
    video_file=$(find "$output_dir" -name "video.*" 2>/dev/null | head -1)
    if [ -n "$video_file" ]; then
      ffmpeg -i "$video_file" -vf "select=gt(scene\,0.3),scale=1280:-1" -vsync vfr -frames:v 20 "$output_dir/keyframes/frame_%03d.png" -y 2>/dev/null || true
      rm -f "$video_file"
    fi
  fi

  # Clean up subtitle files
  rm -f "$output_dir"/subs.* "$output_dir"/subs.en.* 2>/dev/null || true

  generate_summary "$output_dir" "url"
}

# ---------------------------------------------------------------------------
# Ingest local file
# ---------------------------------------------------------------------------
ingest_local() {
  local input="$1"

  if [ ! -f "$input" ]; then
    echo "ERROR: File not found: $input"
    exit 1
  fi

  local filename
  filename=$(basename "$input" | sed 's/\.[^.]*$//')
  local output_dir="$PROJECT_ROOT/shared_context/ingested/${filename}"

  # Check duplicate
  if [ -d "$output_dir" ] && [ -z "$FORCE" ]; then
    echo "Already ingested: $output_dir (use --force to re-ingest)"
    return 0
  fi

  mkdir -p "$output_dir/keyframes"

  # Detect if video or audio-only
  local has_video
  has_video=$(ffprobe -v error -select_streams v -show_entries stream=codec_type -of csv=p=0 "$input" 2>/dev/null || echo "")

  # --- Metadata ---
  local duration
  duration=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$input" 2>/dev/null || echo "unknown")

  {
    echo "# $filename"
    echo "- Source: $input"
    echo "- Duration: ${duration}s"
    echo "- Ingested: $(date +%Y-%m-%d)"
  } > "$output_dir/metadata.md"

  auto_summary_check "$duration"

  # --- Transcribe with whisper ---
  echo "Transcribing..."
  if command -v whisper &>/dev/null; then
    whisper "$input" --output_format txt --output_dir "$output_dir" --language en
    mv "$output_dir"/*.txt "$output_dir/transcript.md" 2>/dev/null || true
  else
    echo "WARNING: whisper not installed. Install with: pip install openai-whisper"
    echo "No transcript available." > "$output_dir/transcript.md"
  fi

  # --- Keyframes (video only) ---
  if [ -n "$has_video" ] && [ -z "$NO_KEYFRAMES" ]; then
    echo "Extracting keyframes..."
    ffmpeg -i "$input" -vf "select=gt(scene\,0.3),scale=1280:-1" -vsync vfr -frames:v 20 "$output_dir/keyframes/frame_%03d.png" -y 2>/dev/null || true
  fi

  generate_summary "$output_dir" "local"
}

# ---------------------------------------------------------------------------
# Batch mode
# ---------------------------------------------------------------------------
run_batch() {
  local batch_file="$1"

  if [ ! -f "$batch_file" ]; then
    echo "ERROR: Batch file not found: $batch_file"
    exit 1
  fi

  while IFS= read -r line; do
    # Skip empty lines and comments
    [ -z "$line" ] && continue
    [[ "$line" =~ ^# ]] && continue
    echo "=========================================="
    echo "Processing: $line"
    echo "=========================================="
    # shellcheck disable=SC2086
    "$0" $PASSTHROUGH_FLAGS "$line"
  done < "$batch_file"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  parse_args "$@"
  check_deps

  # Batch mode
  if [ -n "$BATCH_FILE" ]; then
    run_batch "$BATCH_FILE"
    exit 0
  fi

  # Need an input
  if [ -z "$INPUT" ]; then
    echo "ERROR: No input provided."
    usage
    exit 1
  fi

  # Detect input type
  if [[ "$INPUT" =~ ^https?:// ]]; then
    ingest_url "$INPUT"
  elif [ -f "$INPUT" ]; then
    ingest_local "$INPUT"
  else
    echo "ERROR: '$INPUT' is not a valid URL or existing file."
    exit 1
  fi
}

main "$@"
