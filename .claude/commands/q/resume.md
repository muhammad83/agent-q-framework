---
name: q:resume
description: Resume from a paused session or start fresh from todo.md
triggers: [resume, continue, pick up, restart]
argument-hint: ""
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
autonomy: auto
namespace: dx
---

## Objective
Pick up where the last session left off. Check for a persisted session state,
present status, and route to the next action.

## Execution Context
- Read `workflows/resume.md` for the full resume workflow
- Check for `shared_context/session-state.md`
- Read `todo.md` for project state

## Process

1. **Check for session state.** Look for `shared_context/session-state.md`.

2. **If session state exists:**
   a. Read `shared_context/session-state.md` completely
   b. Read `todo.md` for full project context
   c. Present a summary to the user:
      ```
      RESUMING PAUSED SESSION
      ───────────────────────
      Last session: {date from session-state.md}
      Branch: {branch name}
      You were working on: {current task / context summary}
      Files touched: {count and key files}
      Decisions made: {brief list}
      Blockers: {list or "none"}
      ```
   d. Ask the user to confirm or adjust before continuing:
      - "Continue" — pick up the next remaining task
      - "Review" — show full details of what was done
      - "Re-plan" — the situation has changed, need a new plan
      - "Different task" — work on something else

3. **If no session state found:**
   a. Also check for legacy `.continue-here.md` in project root — if found,
      read it and use it the same way as session-state.md
   b. If neither file exists: read `todo.md`
   c. Scan `workflows/` for active build plans
   d. Present current project state (same format as `/q:progress`)
   e. Ask the user what they'd like to work on

4. **Clean up old session states.** After loading, check the timestamp in
   `shared_context/session-state.md`. If it is older than 7 days, warn the
   user that the session state is stale and ask whether to use it or start
   fresh. Also delete any legacy `.continue-here.md` if it exists and is
   older than 7 days.

5. **Quick resume.** If the user just says "continue" or "go", skip the
   options and immediately pick up the next remaining task from where the
   session left off.

6. **Do not make changes yet.** Wait for user to choose direction before
   modifying any files.

## Success Criteria
- Previous state accurately presented from `shared_context/session-state.md`
- User given clear options for how to proceed
- Stale session states (>7 days) flagged
- No changes made until user confirms direction
