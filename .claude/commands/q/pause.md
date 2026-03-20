---
name: q:pause
description: Save session state for clean handoff to next session
argument-hint: ""
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

## Objective
Capture the current session state so the next session (or a different person)
can pick up exactly where you left off. State is persisted to
`shared_context/session-state.md`.

## Execution Context
- Read `workflows/pause.md` for the full pause workflow
- Read `todo.md` for current state

## Process

1. **Assess current state.** Read `todo.md` and scan recent git history
   (`git log --oneline -10` and `git status`).

2. **Gather session info.** Collect:
   - Current branch name and git status (clean / dirty / untracked files)
   - The current task from todo.md (the in-progress item)
   - Files modified this session (from `git diff --name-only` and untracked files)
   - Key decisions made during this session
   - Any blockers or open questions
   - A brief context summary of what was being worked on

3. **Write session state.** Create or overwrite `shared_context/session-state.md`:

   ```markdown
   # Session State
   _Saved: {YYYY-MM-DD HH:MM}_

   ## Branch & Git Status
   - **Branch:** {branch name}
   - **Status:** {clean / N files modified / N untracked}

   ## Current Task
   {The in-progress task from todo.md}

   ## Files Modified This Session
   - {path/to/file1}
   - {path/to/file2}

   ## What Was Being Worked On
   {1-3 sentence summary of the current work in progress — enough context
   for a cold-start session to understand where things stand}

   ## Key Decisions Made
   - {Decision 1 and reasoning}
   - {Decision 2 and reasoning}

   ## Blockers / Open Questions
   - {Blocker or question, or "None"}

   ## Context Notes
   {Anything else the next session needs — file paths, function names,
   gotchas discovered, links to relevant docs, etc.}
   ```

4. **Update todo.md.** Add a session log entry under the `## Session Log`
   section (create the section if it doesn't exist) with:
   - Date and time
   - What was done
   - What's next
   - Blockers (if any)

5. **WIP commit.** If there are uncommitted changes:
   - Stage all modified files individually
   - Commit: `chore(wip): pause — {brief description of state}`

6. **Confirm.** Tell the user:
   > Session paused. State saved to `shared_context/session-state.md` and
   > `todo.md` updated.
   > Next session: run `/q:resume` or just say "continue" to pick up.

## Success Criteria
- `shared_context/session-state.md` exists with all sections filled
- `todo.md` updated with session log entry
- All changes committed (even as WIP)
- User knows how to resume
