# Build Plan C: DX — Hook Profiles + Session Persistence

## Goal
Add configurable hook profiles (minimal/standard/strict) so lightweight projects don't pay full hook cost, and upgrade pause/resume to auto-save/load session context.

## Discovery Level
Level 1 — Quick verify.

## Tasks

### Task 1: Hook profiles
- Create `tools/hook-profile.cjs` — reads `AGENT_Q_HOOK_PROFILE` env var (default: `standard`)
  - `minimal` — statusline only, no security scan, no context monitor
  - `standard` — statusline + context monitor + security scan
  - `strict` — all hooks + pre-commit verification + lint on save
- Modify context monitor hook to check profile before running
- Modify security scan (from Plan B) to check profile before running
- Document profiles in `context/rules.md`

### Task 2: Session persistence (upgrade pause/resume)
- Modify `.claude/commands/q/pause.md`:
  - Auto-save to `shared_context/session-state.md`: current task, files modified, decisions made, blockers, git branch/status
  - Save context summary (not raw conversation)
  - Timestamp the save
- Modify `.claude/commands/q/resume.md`:
  - Auto-detect `shared_context/session-state.md`
  - Load state and present summary: "Last session on [date], you were working on [task], these files were modified: [...], these decisions were made: [...]"
  - Ask user to confirm or adjust before continuing
  - Clean up stale session states (>7 days old)

### Task 3: Update todo.md

## Files
| Action | File |
|---|---|
| Create | `tools/hook-profile.cjs` |
| Modify | `.claude/commands/q/pause.md` |
| Modify | `.claude/commands/q/resume.md` |
| Modify | `context/rules.md` (document profiles) |
| Modify | `todo.md` |

## Edge Cases
- No env var set → default to `standard`
- Session state file from a different branch → warn user
- Multiple paused sessions → show list, let user pick

## Verification
- Set `AGENT_Q_HOOK_PROFILE=minimal`, verify only statusline runs
- Run `/q:pause`, check session-state.md is created
- Run `/q:resume`, verify it loads correctly

## Rollback
New files + modified commands. Git revert handles everything.
