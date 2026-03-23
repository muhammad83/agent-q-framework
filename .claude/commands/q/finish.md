---
name: q:finish
description: Finish current branch with verification and completion options
triggers: [finish, done, complete, wrap up, merge, ship]
argument-hint: "[optional: base branch, default main]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
autonomy: confirm
namespace: dx
---

## Objective
Finish the current feature branch by running verification, presenting the user with
completion options (merge, PR, keep, discard), and executing the chosen option.

## Execution Context
- Load `workflows/finish-branch.md` for the full workflow definition
- Read `todo.md` for current project state

## Process

1. **Detect branch context.**
   ```bash
   CURRENT_BRANCH=$(git branch --show-current)
   BASE_BRANCH=${1:-main}
   ```
   If `CURRENT_BRANCH` equals `BASE_BRANCH`, stop with:
   "Already on main -- nothing to finish."

2. **Check for uncommitted changes.**
   ```bash
   git status --porcelain
   ```
   If output is non-empty, prompt user to commit or stash before continuing.

3. **Count commits ahead.**
   ```bash
   COMMITS_AHEAD=$(git rev-list --count $BASE_BRANCH..HEAD)
   ```

4. **Run pre-completion checklist** (from `workflows/finish-branch.md` Step 3):
   - Run test suite (detect runner automatically)
   - Run linter/formatter if configured
   - Check if base branch has new commits

5. **Present context summary.**
   Report: branch name, commits ahead, test results, lint status, base branch freshness.

6. **Present 4 options** (from `workflows/finish-branch.md` Step 5):
   - Option 1: Merge locally
   - Option 2: Create PR (using `gh pr create`)
   - Option 3: Keep branch as-is
   - Option 4: Discard branch (requires explicit confirmation)

7. **Execute chosen option** per the workflow definition.

8. **Update todo.md** with completion status.

## Success Criteria
- Current branch detected and validated (not on main)
- Pre-completion checklist ran
- User presented with context summary and all 4 options
- Chosen option executed cleanly
- `todo.md` updated with completion status
