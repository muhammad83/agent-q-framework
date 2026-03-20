---
name: q:progress
description: Show current project state and recommend next actions
triggers: [progress, status, state, where are we]
argument-hint: ""
allowed-tools: [Read, Glob]
---

## Objective
Read project state and present a clear status report with recommended next action.

## Execution Context
- Read `todo.md` for current state
- Read `context/` for rules and protocols
- Scan `workflows/` for active build plans

## Process

1. **Read state.** Read `todo.md` completely.

2. **Scan for plans.** Check `workflows/` for any `build-plan-*.md` files.

3. **Check for continuation.** Look for `.continue-here.md` in the project root
   (indicates a paused session).

4. **Present status:**
   ```
   PROJECT STATE
   ─────────────
   Current Goal: [from todo.md]
   Active Tasks: [count] ([count] completed, [count] remaining)
   Active Plans: [list any build-plan-*.md files]
   Known Issues: [count]
   Last Session: [date and summary from session log]
   ```

5. **Recommend next action.** Based on state:
   - If `.continue-here.md` exists → "Resume paused work? Run `/q:resume`"
   - If active tasks exist → "Continue with: [next task]"
   - If plan exists but no tasks started → "Execute plan? Run `/q:execute {plan}`"
   - If no plan exists → "Ready to plan? Run `/q:plan`"
   - If all tasks done → "All tasks complete. Run `/q:review` or start next feature."

6. **Do not make any changes.** This is read-only.

## Success Criteria
- Status report shown with all sections filled
- Clear recommended next action
- No files modified
