#!/usr/bin/env node

/**
 * Agent Q — Context Window Status Line
 *
 * Reads context_window stats from Claude Code's stdin, computes a visual
 * progress bar, writes a bridge file for the context monitor hook, and
 * outputs a formatted status line.
 *
 * Usage: configured as statusLine in .claude/settings.json
 *   "statusLine": "node hooks/agentq-statusline.js"
 *
 * Bridge file: /tmp/claude-ctx-{session_id}.json
 *   Used by agentq-context-monitor.js to inject warnings.
 */

const CEILING = 0.80; // Claude's real usable limit before quality tanks

function buildProgressBar(pct, width = 20) {
  const filled = Math.round((pct / 100) * width);
  const empty = width - filled;
  const bar = "\u2588".repeat(filled) + "\u2591".repeat(empty);

  let color;
  if (pct <= 30) color = "\x1b[32m";      // green — PEAK
  else if (pct <= 50) color = "\x1b[33m";  // yellow — GOOD
  else if (pct <= 70) color = "\x1b[33m";  // yellow — DEGRADING
  else color = "\x1b[31m";                 // red — POOR

  const reset = "\x1b[0m";
  return `${color}${bar}${reset} ${pct}%`;
}

function getZoneLabel(pct) {
  if (pct <= 30) return "PEAK";
  if (pct <= 50) return "GOOD";
  if (pct <= 70) return "DEGRADING";
  return "POOR";
}

function processInput(data) {
  try {
    const parsed = JSON.parse(data);
    const cw = parsed.context_window;
    if (!cw) return;

    const remaining = cw.remaining_percentage || 0;
    // Scale remaining to account for the 80% ceiling
    const scaledRemaining = Math.max(0, Math.min(100, (remaining / (CEILING * 100)) * 100));
    const used = Math.round(100 - scaledRemaining);
    const zone = getZoneLabel(used);
    const bar = buildProgressBar(used);

    // Write bridge file for context monitor
    const sessionId = process.env.CLAUDE_SESSION_ID || "default";
    const bridgePath = `/tmp/claude-ctx-${sessionId}.json`;
    const bridgeData = {
      used_pct: used,
      remaining_pct: Math.round(scaledRemaining),
      raw_remaining: remaining,
      zone: zone,
      timestamp: Date.now()
    };

    const fs = require("fs");
    fs.writeFileSync(bridgePath, JSON.stringify(bridgeData));

    // Output status line
    process.stdout.write(`Q: ${bar} ${zone}`);
  } catch {
    // Silently ignore parse errors — stdin may have non-JSON content
  }
}

// Read from stdin
let input = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => { input += chunk; });
process.stdin.on("end", () => { processInput(input); });
