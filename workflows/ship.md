# Workflow: Ship

## Trigger
Run this when the user wants to ship code: create a PR, push changes, deploy, or
merge a feature branch. This is the full PR pipeline -- for branch cleanup only,
use `workflows/finish-branch.md` instead.

## Context Needed
Before running, make sure you have:
- [ ] Current branch name (must NOT be on the base branch)
- [ ] `todo.md` for current project state
- [ ] `CLAUDE.md` for project-specific test commands

## Steps

### Step 0: Detect base branch

Determine which branch this PR targets. Use the result as "the base branch"
throughout all subsequent steps.

1. Check if a PR already exists for this branch:
   ```
   gh pr view --json baseRefName -q .baseRefName
   ```
   If this succeeds, use the printed branch name.

2. If no PR exists, detect the repo's default branch:
   ```
   gh repo view --json defaultBranchRef -q .defaultBranchRef.name
   ```

3. If both commands fail, fall back to `main`.

---

### Step 1: Pre-flight

1. **Branch guard.** If on the base branch, abort: "You're on the base branch.
   Ship from a feature branch."

2. **Check status.** Run `git status` (never use `-uall`). Note any uncommitted
   changes -- they will be included in the ship.

3. **Gather context.** Run:
   ```
   git diff <base>...HEAD --stat
   git log <base>..HEAD --oneline
   ```
   Understand the scope of what is being shipped.

---

### Step 2: Merge the base branch

Fetch and merge the base branch so tests run against the merged state:

```
git fetch origin <base> && git merge origin/<base> --no-edit
```

- **Merge conflicts:** Try auto-resolving simple conflicts (VERSION, CHANGELOG
  ordering). If conflicts are complex, STOP and show them to the user.
- **Already up to date:** Continue silently.

---

### Step 3: Run tests

Run the project's test suite on the merged code.

**Detect the test command:**
1. Read `CLAUDE.md` for a `## Testing` section with a test command.
2. If not found, auto-detect: look for `package.json` scripts (`test`),
   `pytest.ini`, `pyproject.toml`, `Makefile` test target, `.rspec`, `go.mod`, etc.
3. If no test command can be found, ask the user: "What command runs your tests?"

Run the detected test command.

**If tests fail:**
1. Classify each failure as **in-branch** or **pre-existing**:
   - Run `git diff origin/<base>...HEAD --name-only` to see changed files.
   - **In-branch:** The failing test or the code it tests was modified on this branch.
   - **Pre-existing:** Neither was modified. Default to in-branch when ambiguous.
2. **In-branch failures:** STOP. Show them. The user must fix before shipping.
3. **Pre-existing failures:** Ask the user:
   - A) Fix now
   - B) Add to Known Issues in `todo.md` and continue
   - C) Skip -- ship anyway

**If all pass:** Continue silently, noting the count.

---

### Step 4: Review diff

Review the full diff for structural issues that tests do not catch.

1. Run `git diff origin/<base>...HEAD` to get the full diff.

2. Review in two passes:
   - **Pass 1 (Critical):** Security issues (SQL injection, XSS, secrets in code,
     unsafe deserialization), data safety (destructive migrations, missing backups).
   - **Pass 2 (Informational):** Dead code, stale comments, missing error handling,
     N+1 queries, performance concerns.

3. Classify each finding:
   - **AUTO-FIX:** Mechanical fixes (dead code removal, stale comments, obvious bugs).
     Apply the fix. Output: `[AUTO-FIXED] [file:line] Problem -> what you did`
   - **ASK:** Judgment calls (architecture, security, large changes). Present to
     the user with a recommendation and options: A) Fix B) Skip.

4. **If any fixes were applied:** Commit fixed files individually:
   ```
   git commit -m "fix: pre-ship review fixes"
   ```

5. Output summary: `Pre-Ship Review: N issues -- M auto-fixed, K asked`

---

### Step 5: Version bump (if VERSION exists)

1. Check if a `VERSION` file exists in the repo root. If not, skip this step.

2. Read the current version.

3. Auto-decide the bump level based on the diff:
   - **PATCH:** Default for most changes (bug fixes, small-medium features).
   - **MINOR:** Ask the user -- only for major features or significant changes.
   - **MAJOR:** Ask the user -- only for breaking changes or milestones.

4. Write the new version to the `VERSION` file.

---

### Step 6: Update CHANGELOG (if it exists)

1. Check if `CHANGELOG.md` exists. If not, skip this step.

2. Read the header to understand the existing format.

3. Auto-generate an entry from all commits on the branch:
   - Use `git log <base>..HEAD --oneline` for commit history.
   - Use `git diff <base>...HEAD` for the full diff.
   - Categorize into: Added, Changed, Fixed, Removed (use only sections that apply).
   - Write concise, user-facing bullet points. Lead with what the user can now DO.
   - Date format: `YYYY-MM-DD`.

4. Insert the entry after the file header.

---

### Step 7: Commit

Group changes into logical, bisectable commits.

1. **Commit ordering** (earlier first):
   - Infrastructure (migrations, config, routes)
   - Models and services (with their tests)
   - Controllers and views (with their tests)
   - VERSION + CHANGELOG in the final commit

2. **Rules:**
   - A module and its test file go in the same commit.
   - Each commit must be independently valid (no broken imports).
   - Stage files individually -- never `git add .` or `git add -A`.
   - If the total diff is small (< 50 lines, < 4 files), a single commit is fine.

3. **Commit message format:** `{type}({scope}): {description}`
   - Types: feat, fix, chore, refactor, docs, test
   - Only the final commit gets the co-author trailer.

---

### Step 8: Push

Push to the remote with upstream tracking:

```
git push -u origin <branch-name>
```

Never force push.

---

### Step 9: Create PR

Create a pull request using `gh`:

```
gh pr create --base <base> --title "<type>(<scope>): <summary>" --body "$(cat <<'EOF'
## Summary
<bullet points summarizing what this PR does>

## Test plan
- [ ] All tests pass (N tests, 0 failures)
- [ ] Pre-ship review: <summary of findings>
- [ ] <any manual verification steps>
EOF
)"
```

Output the PR URL.

---

### Step 10: Update state

Update `todo.md` with the shipped PR URL and completion status.

## Tools Used
- git (status, diff, log, fetch, merge, add, commit, push, branch)
- gh (pr view, pr create, repo view)
- Project test runner (detected from CLAUDE.md or auto-detected)

## Output
- PR created on GitHub with structured body
- `todo.md` updated with PR reference
- VERSION and CHANGELOG updated (if they exist)

## Success Criteria
- Branch is not the base branch
- Base branch merged before testing
- All in-branch tests pass
- Diff reviewed for critical issues
- Files committed in bisectable chunks
- PR created with Summary + Test plan sections
- `todo.md` updated

## Edge Cases
- **On base branch:** Abort immediately with message
- **Merge conflicts:** Show conflicts, STOP for user resolution
- **No test command found:** Ask the user for the test command
- **Test failures:** Triage as in-branch vs pre-existing (see Step 3)
- **gh CLI not installed:** Fall back to `git push` and provide manual PR URL
- **No VERSION file:** Skip version bump silently
- **No CHANGELOG.md:** Skip changelog update silently
- **Pre-existing test failures:** Offer fix/TODO/skip options
- **No uncommitted changes:** Ship whatever is already committed on the branch
