# Build Plan C: Parallel Execution Hardening

## Goal
Add per-agent config isolation to Spin Jit Su and FIFO caching to the context monitor hook so parallel agents don't collide and redundant bridge file reads are eliminated.

## Discovery Level
Level 1 — Quick verify on current hook/bridge file behavior.

## Tasks

### Task 1: Per-Agent Config Isolation for Spin Jit Su
Add `AGENTQ_INSTANCE_ID` env var support so parallel executors get isolated state.

**Changes to `tools/statusline.cjs`:**
- Read `AGENTQ_INSTANCE_ID` env var (fall back to `CLAUDE_SESSION_ID`, then "default")
- Use it in bridge file path: `/tmp/claude-ctx-${instanceId}.json`

**Changes to `hooks/agentq-context-monitor.js`:**
- Same `AGENTQ_INSTANCE_ID` support for bridge and state file paths

**Changes to `workflows/spin-jit-su-workflow.md`:**
- Document that each parallel stream gets a unique `AGENTQ_INSTANCE_ID`
- Add env var to the tmux launch commands

**Changes to `tools/spin-jit-su.sh`** (if exists):
- Export `AGENTQ_INSTANCE_ID=stream-{n}` before launching each Claude instance

### Task 2: FIFO Cache for Context Monitor
Add a simple cache to `hooks/agentq-context-monitor.js` to avoid re-reading and re-processing the bridge file when nothing has changed.

**Implementation:**
- Read bridge file timestamp before parsing
- Compare with last-seen timestamp from state file
- If unchanged, skip processing entirely
- Add `last_bridge_mtime` field to state file (`/tmp/claude-ctx-state-${instanceId}.json`)

**Cache eviction:**
- No eviction needed — state file is per-session, cleaned up naturally
- Bridge file timestamp changes whenever statusline writes new data

## Files

| Action | File |
|--------|------|
| Modify | `tools/statusline.cjs` — add AGENTQ_INSTANCE_ID support |
| Modify | `hooks/agentq-context-monitor.js` — add instance ID + FIFO cache |
| Modify | `workflows/spin-jit-su-workflow.md` — document isolation |
| Modify | `tools/spin-jit-su.sh` — export instance ID per stream (if file exists) |

## Edge Cases
- `AGENTQ_INSTANCE_ID` not set — fall back to existing behavior (CLAUDE_SESSION_ID → "default")
- Bridge file doesn't exist yet — skip cache check, same as current behavior
- Multiple agents write to same bridge file race condition — instance ID prevents this
- `spin-jit-su.sh` may not exist — create it or skip, document manual env var setup

## Verification
- Run two statusline instances with different AGENTQ_INSTANCE_ID — verify separate bridge files
- Run context monitor twice with unchanged bridge — verify second run skips processing
- Run context monitor with changed bridge — verify it processes normally
- Spin Jit Su workflow docs mention instance isolation

## Rollback
Remove `AGENTQ_INSTANCE_ID` references. Revert to `CLAUDE_SESSION_ID` fallback only.
