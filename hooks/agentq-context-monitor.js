#!/usr/bin/env node

/**
 * Agent Q — Context Window Monitor (PostToolUse Hook)
 *
 * Reads the bridge file written by agentq-statusline.js and injects
 * warnings when the context window is getting low.
 *
 * Usage: configured as PostToolUse hook in .claude/settings.json
 *   "hooks": {
 *     "PostToolUse": [{ "type": "command", "command": "node hooks/agentq-context-monitor.js" }]
 *   }
 *
 * Warning levels:
 *   - WARNING at 35% remaining (65% used) — suggest wrapping up
 *   - CRITICAL at 25% remaining (75% used) — commit and clear
 *
 * Debounce: only warns every 5 tool calls (severity escalation bypasses debounce)
 */

const fs = require("fs");
const path = require("path");

const WARNING_THRESHOLD = 35;   // remaining %
const CRITICAL_THRESHOLD = 25;  // remaining %
const DEBOUNCE_CALLS = 5;

// Track state via a temp file (hooks are stateless between calls)
const sessionId = process.env.CLAUDE_SESSION_ID || "default";
const bridgePath = `/tmp/claude-ctx-${sessionId}.json`;
const statePath = `/tmp/claude-ctx-state-${sessionId}.json`;

function readJSON(filepath) {
  try {
    return JSON.parse(fs.readFileSync(filepath, "utf8"));
  } catch {
    return null;
  }
}

function writeJSON(filepath, data) {
  fs.writeFileSync(filepath, JSON.stringify(data));
}

function main() {
  const bridge = readJSON(bridgePath);
  if (!bridge) return; // No data yet — statusline hasn't run

  const remaining = bridge.remaining_pct;
  const used = bridge.used_pct;

  // Determine severity
  let severity = null;
  if (remaining <= CRITICAL_THRESHOLD) severity = "CRITICAL";
  else if (remaining <= WARNING_THRESHOLD) severity = "WARNING";

  if (!severity) return; // Context is fine, no warning needed

  // Check debounce state
  let state = readJSON(statePath) || { callsSinceLastWarning: 0, lastSeverity: null };
  state.callsSinceLastWarning++;

  // Severity escalation bypasses debounce
  const escalated = state.lastSeverity === "WARNING" && severity === "CRITICAL";
  const debounceExpired = state.callsSinceLastWarning >= DEBOUNCE_CALLS;

  if (!debounceExpired && !escalated) {
    writeJSON(statePath, state);
    return;
  }

  // Reset debounce counter
  state.callsSinceLastWarning = 0;
  state.lastSeverity = severity;
  writeJSON(statePath, state);

  // Output warning to stderr (Claude Code displays hook stderr as user-visible messages)
  if (severity === "CRITICAL") {
    process.stderr.write(
      `\n[AGENT Q] CRITICAL: Context window at ${used}% (${remaining}% remaining).\n` +
      `Quality is degrading. Commit your work now, then /compact or /clear.\n` +
      `Do NOT start new tasks. Finish what you're doing and save state to todo.md.\n`
    );
  } else {
    process.stderr.write(
      `\n[AGENT Q] WARNING: Context window at ${used}% (${remaining}% remaining).\n` +
      `Start wrapping up the current task. Commit when done.\n` +
      `Consider /compact to free up space if more work is needed.\n`
    );
  }
}

main();
