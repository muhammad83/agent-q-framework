---
name: q:resume
description: Resume from a paused session or start fresh from todo.md
argument-hint: ""
allowed-tools: [Read, Glob, Grep]
---

## Objective
Pick up where the last session left off. Check for a paused state file,
present status, and route to the next action.

## Execution Context
- Read `workflows/resume.md` for the full resume workflow
- Check for `.continue-here.md` in project root
- Read `todo.md` for project state

## Process

1. **Check for pause file.** Look for `.continue-here.md` in the project root.

2. **If pause file exists:**
   a. Read `.continue-here.md` completely
   b. Read `todo.md` for full context
   c. Present status:
      ```
      RESUMING PAUSED SESSION
      ───────────────────────
      Paused: {date}
      Where stopped: {summary}
      Completed: {list}
      Remaining: {list}
      Blockers: {list or "none"}
      ```
   d. Offer options:
      - "Continue" → pick up the next remaining task
      - "Review" → show what was done before continuing
      - "Re-plan" → the situation has changed, need a new plan
      - "Different task" → work on something else

3. **If no pause file:**
   a. Read `todo.md`
   b. Scan `workflows/` for active build plans
   c. Present current state (same format as `/q:progress`)
   d. Recommend next action

4. **Quick resume.** If the user just says "continue" or "go", skip the
   options and immediately pick up the next remaining task.

5. **Do not make changes yet.** Wait for user to choose direction.

## Success Criteria
- Previous state accurately presented
- User given clear options for how to proceed
- No changes made until user confirms direction
