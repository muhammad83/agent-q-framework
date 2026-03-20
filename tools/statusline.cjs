#!/usr/bin/env node

/**
 * Agent Q — Status Line
 *
 * Shows context window usage with a visual progress bar, zone label,
 * and token counts. Writes bridge file for context monitor hook.
 *
 * Usage: configured as statusLine in ~/.claude/settings.json
 *   "statusLine": { "type": "command", "command": "node <path>/tools/statusline.cjs" }
 */

function buildProgressBar(pct, width = 20) {
  const filled = Math.round((pct / 100) * width);
  const empty = width - filled;
  const bar = "\u2588".repeat(filled) + "\u2591".repeat(empty);

  let color;
  if (pct <= 30) color = "\x1b[32m";      // green
  else if (pct <= 50) color = "\x1b[33m";  // yellow
  else if (pct <= 70) color = "\x1b[33m";  // yellow
  else color = "\x1b[31m";                 // red

  return `${color}${bar}\x1b[0m`;
}

function getZoneLabel(pct) {
  if (pct <= 30) return "\x1b[32mPEAK\x1b[0m";
  if (pct <= 50) return "\x1b[33mGOOD\x1b[0m";
  if (pct <= 70) return "\x1b[33mDEGRADING\x1b[0m";
  return "\x1b[31mPOOR\x1b[0m";
}

function formatTokens(n) {
  if (!n) return "0";
  if (n >= 1000) return Math.round(n / 1000) + "k";
  return String(n);
}

function processInput(data) {
  try {
    const parsed = JSON.parse(data);
    const cw = parsed.context_window;
    if (!cw) return;

    // used_percentage is provided directly by Claude Code
    const used = Math.round(cw.used_percentage || (100 - (cw.remaining_percentage || 0)));
    const zone = getZoneLabel(used);
    const bar = buildProgressBar(used);

    // Token counts
    const inputTokens = cw.total_input_tokens || 0;
    const outputTokens = cw.total_output_tokens || 0;
    const windowSize = cw.context_window_size || 200000;

    // Write bridge file for context monitor
    const sessionId = parsed.session_id || process.env.CLAUDE_SESSION_ID || "default";
    const bridgePath = `/tmp/claude-ctx-${sessionId}.json`;
    const bridgeData = {
      used_pct: used,
      remaining_pct: 100 - used,
      zone: used <= 30 ? "PEAK" : used <= 50 ? "GOOD" : used <= 70 ? "DEGRADING" : "POOR",
      timestamp: Date.now()
    };

    const fs = require("fs");
    fs.writeFileSync(bridgePath, JSON.stringify(bridgeData));

    // Output: Q: [████░░░░░░░░░░░░░░░░] PEAK | 23k/200k
    process.stdout.write(`Q: ${bar} ${used}% ${zone} | ${formatTokens(inputTokens)}in/${formatTokens(outputTokens)}out [${formatTokens(windowSize)} window]`);
  } catch {
    // Silently ignore parse errors
  }
}

let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => { input += chunk; });
process.stdin.on("end", () => { processInput(input); });
