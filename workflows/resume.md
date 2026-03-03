# Workflow: Session Resume

## Trigger
Run this at the start of any new session, or when a user says "continue",
"resume", "pick up where we left off", or runs `/q:resume`.

## Context Needed
Before running, make sure you have:
- [ ] Access to project root (to check for `.continue-here.md`)
- [ ] Access to `todo.md`

## Steps

1. **Check for `.continue-here.md`** in the project root.

2. **If `.continue-here.md` exists** (paused session):
   a. Read it completely
   b. Read `todo.md` for full context
   c. Read `context/rules.md` and `context/planning-protocol.md`
   d. Present status to the user:
      ```
      RESUMING PAUSED SESSION
      ───────────────────────
      Paused: {date from file}
      Where stopped: {from file}
      Completed: {from file}
      Remaining: {from file}
      Blockers: {from file or "none"}
      ```
   e. Offer options:
      - **Continue** — pick up the next remaining task immediately
      - **Review** — show what was done last session before continuing
      - **Re-plan** — situation changed, need a new plan
      - **Different task** — switch to something else

3. **If no `.continue-here.md`** (fresh start):
   a. Read `todo.md`
   b. Scan `workflows/` for `build-plan-*.md` files
   c. Read `context/rules.md` and `context/planning-protocol.md`
   d. Present current state:
      ```
      PROJECT STATE
      ─────────────
      Current Goal: {from todo.md}
      Active Tasks: {count}
      Active Plans: {list build-plan files}
      Known Issues: {count}
      Last Session: {from session log}
      ```
   e. Recommend next action based on state

4. **Quick resume mode.** If the user says just "continue" or "go":
   - Skip the options menu
   - Pick up the first remaining task from `.continue-here.md` or `todo.md`
   - Start working immediately

5. **After user chooses direction:**
   - If continuing: delete `.continue-here.md` (it's served its purpose)
   - Begin the chosen work

## Tools Used
- File read (`.continue-here.md`, `todo.md`, context files)
- File delete (`.continue-here.md` after resuming)

## Output
- Status report presented to user
- Direction confirmed
- `.continue-here.md` deleted after resuming

## Success Criteria
- Previous session state accurately reconstructed
- User given clear options without being forced into one path
- No changes made until user confirms direction
- `.continue-here.md` cleaned up after use

## Edge Cases
- **Multiple `.continue-here.md` files** — shouldn't happen, but if it does,
  read the most recent one (check the "Paused:" timestamp).
- **Stale pause file** — if the pause file is more than a week old, warn the
  user that things may have changed and suggest reviewing `todo.md` instead.
- **WIP commit exists** — note that the last commit may be a WIP and offer
  to amend it with the next real commit.
- **"continue" with no pause file and no tasks** — there's nothing to resume.
  Suggest `/q:plan` to start something new.
