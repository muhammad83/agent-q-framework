# Workflow: Session Pause

## Trigger
Run this when ending a session mid-task, or when context is getting heavy
and you need to hand off to a fresh session.

## Context Needed
Before running, make sure you have:
- [ ] Current state of `todo.md`
- [ ] Knowledge of what was accomplished this session
- [ ] Any uncommitted changes identified

## Steps

1. **Read `todo.md`** for current project state.

2. **Scan uncommitted work.** Run `git status` and `git diff --stat` to see
   what changed since the last commit.

3. **Write `.continue-here.md`** in the project root with:
   ```markdown
   # Continue Here
   _Paused: {YYYY-MM-DD HH:MM}_

   ## Where I Stopped
   [Exact file, function, or task you were working on]
   [What state is it in — compiles? partially done? broken?]

   ## What's Done
   - [Completed item 1]
   - [Completed item 2]

   ## What's Left
   - [ ] [Remaining task 1]
   - [ ] [Remaining task 2]

   ## Key Decisions Made
   - [Decision 1 — and why]
   - [Decision 2 — and why]

   ## Active Blockers
   - [Blocker or "None"]

   ## Context Notes
   [File paths, function names, or domain details the next session needs]
   [Anything not captured in todo.md]
   ```

4. **Update `todo.md`** session log:
   ```markdown
   ### Session N — {date}
   - What was done: [summary]
   - What's next: [next task from plan]
   - Blockers: [list or "none"]
   ```

5. **WIP commit** if there are uncommitted changes:
   - Stage files individually (never `git add .`)
   - `chore(wip): pause — {brief state description}`

6. **Confirm** to the user that state is saved.

## Tools Used
- Git (status, diff, add, commit)
- File write (`.continue-here.md`)

## Output
- `.continue-here.md` in project root
- Updated `todo.md` with session log entry
- WIP commit (if needed)

## Success Criteria
- `.continue-here.md` has all 6 sections filled
- `todo.md` session log is current
- No uncommitted changes remain
- A fresh session running `/q:resume` can pick up seamlessly

## Edge Cases
- **Nothing to pause** — if all tasks are done and committed, skip the WIP commit.
  Still write `.continue-here.md` noting "all tasks complete."
- **Broken state** — if the code doesn't compile, note this prominently in
  "Where I Stopped" so the next session fixes it first.
- **Multiple active plans** — note which plan was active in "Context Notes."
