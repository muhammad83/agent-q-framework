# Workflow: Finish Branch

## Trigger
Run this when a feature branch is complete and ready to be merged, preserved, or discarded.

## Context Needed
Before running, make sure you have:
- [ ] Current branch name and base branch (usually `main`)
- [ ] Number of commits ahead of base branch
- [ ] `todo.md` for current project state

## Steps

### Step 1 -- Guard: Reject if on main
Check the current branch. If already on `main` (or the configured base branch),
reject with: "Already on main -- nothing to finish."

### Step 2 -- Guard: Check for uncommitted changes
Run `git status --porcelain`. If there are uncommitted changes:
- Inform the user: "You have uncommitted changes."
- Ask: commit them, stash them, or abort?
- Do NOT proceed until changes are handled.

### Step 3 -- Pre-completion checklist
Run verification before offering options:

1. **Test suite.** Run the project's test command (detect from package.json, pytest,
   Makefile, etc.). If tests fail, report failures and ask if user wants to proceed anyway.
2. **Linter/formatter.** If a lint/format command is configured, run it. Report any issues.
3. **Up-to-date check.** Run `git fetch origin` and compare:
   ```bash
   git rev-list --count HEAD..origin/main
   ```
   If base branch has new commits, inform the user and suggest rebasing.

### Step 4 -- Gather context
Collect information for the user:
- Current branch name
- Number of commits ahead of base: `git rev-list --count main..HEAD`
- Test results (pass/fail)
- Any lint warnings
- Whether base branch has diverged

Present a summary, e.g.:
"Branch `feat/my-feature` is 3 commits ahead of main. All tests passing. Main has 0 new commits."

### Step 5 -- Present 4 options
Present these options to the user:

**Option 1 -- Merge locally**
```bash
git checkout main
git merge <branch-name>
git branch -d <branch-name>
```
After merge, delete the feature branch.

**Option 2 -- Create PR**
```bash
git push -u origin <branch-name>
gh pr create --title "<auto-title>" --body "<auto-body from commits>"
```
Auto-generate title from branch name (e.g., `feat/visual-brainstorm` becomes
"feat: visual brainstorm"). Auto-generate body from commit messages.
Report the PR URL to the user.

**Option 3 -- Keep branch**
Leave the branch as-is. Report current status (commits ahead, test status).
No action taken.

**Option 4 -- Discard branch**
This is destructive. Require explicit confirmation:
"This will delete branch `<name>` and all its commits. Type the branch name to confirm."
```bash
git checkout main
git branch -D <branch-name>
```

### Step 6 -- Post-completion
- If merge: confirm merge was clean, report that feature branch was deleted
- If PR: report the PR URL
- If keep: report branch status summary
- If discard: confirm branch was deleted
- Update `todo.md` with completion status

## Tools Used
- git (status, checkout, merge, branch, push, fetch, rev-list, log)
- gh (pr create -- for Option 2)
- Project test runner (detected automatically)

## Output
- `todo.md` updated with branch completion status
- If PR: PR URL reported to user

## Success Criteria
- Pre-completion checklist ran (tests, lint, uncommitted changes, up-to-date check)
- User was presented with all 4 options and context
- Chosen option executed cleanly
- `todo.md` updated

## Edge Cases
- **On main branch:** Reject immediately with message, do not proceed
- **Uncommitted changes:** Prompt to commit or stash before proceeding
- **Merge conflicts:** Report the conflict details, do NOT auto-resolve. Let the user decide how to handle it. Suggest: resolve manually, abort merge, or keep branch for now.
- **No test runner found:** Skip test step, inform user "No test runner detected -- skipping tests"
- **gh CLI not installed:** For Option 2, fall back to reporting the git push command and manual PR URL
- **Remote push fails:** Report the error (e.g., no upstream, permission denied) and suggest fixes
- **Branch has no commits ahead:** Inform user "Branch has no new commits compared to main" and still offer options
