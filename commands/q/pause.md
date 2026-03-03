---
name: q:pause
description: Save session state for clean handoff to next session
argument-hint: ""
allowed-tools: [Read, Write, Edit, Bash, Glob]
---

## Objective
Capture the current session state so the next session (or a different person)
can pick up exactly where you left off.

## Execution Context
- Read `workflows/pause.md` for the full pause workflow
- Read `todo.md` for current state

## Process

1. **Assess current state.** Read `todo.md` and scan recent git history.

2. **Capture position.** Write `.continue-here.md` in the project root:

   ```markdown
   # Continue Here
   _Paused: {date and time}_

   ## Where I Stopped
   [Exactly what you were doing when you stopped]

   ## What's Done
   [List of completed work this session]

   ## What's Left
   [Remaining tasks from the current plan]

   ## Key Decisions Made
   [Decisions that affect remaining work]

   ## Active Blockers
   [Anything preventing progress — missing info, broken deps, etc.]

   ## Context Notes
   [Anything the next session needs to know that isn't in todo.md]
   [Include file paths, function names, specific details]
   ```

3. **Update todo.md.** Add a session log entry with:
   - What was done
   - What's next
   - Blockers

4. **WIP commit.** If there are uncommitted changes:
   - Stage all modified files individually
   - Commit: `chore(wip): pause — {brief description of state}`

5. **Confirm.** Tell the user:
   > Session paused. State saved to `.continue-here.md` and `todo.md`.
   > Next session: run `/q:resume` or just say "continue" to pick up.

## Success Criteria
- `.continue-here.md` exists with all sections filled
- `todo.md` updated with session log
- All changes committed (even as WIP)
- User knows how to resume
