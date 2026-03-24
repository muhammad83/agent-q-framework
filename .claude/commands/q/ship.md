---
name: q:ship
description: Ship current branch -- run tests, review diff, create PR
triggers: [ship, deploy, push, create pr, send it]
argument-hint: "[optional: base branch, default auto-detected]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
autonomy: confirm
namespace: dx
---

## Objective
Ship the current feature branch by running the full PR pipeline: merge base,
run tests, review diff, bump version, update changelog, commit, push, create PR.

## Execution Context
- Read `workflows/ship.md` for the full workflow definition
- Read `context/rules.md` for atomic commit format and deviation rules
- Read `CLAUDE.md` for project-specific test commands
- Read `todo.md` for current project state

## Process

1. **Load workflow.** Read `workflows/ship.md`.

2. **Detect base branch.** Follow Step 0: check `gh pr view`, then `gh repo view`,
   then fall back to `main`. If an argument was provided, use that as the base branch.

3. **Pre-flight.** Follow Step 1: verify not on base branch, check git status,
   gather diff context.

4. **Merge base.** Follow Step 2: fetch and merge the base branch so tests run
   against the latest merged state.

5. **Run tests.** Follow Step 3: detect test command from CLAUDE.md or auto-detect,
   run tests, triage any failures as in-branch vs pre-existing.

6. **Review diff.** Follow Step 4: two-pass review (critical + informational),
   auto-fix mechanical issues, ask about judgment calls.

7. **Version bump.** Follow Step 5: if VERSION file exists, auto-bump PATCH or
   ask for MINOR/MAJOR.

8. **Update CHANGELOG.** Follow Step 6: if CHANGELOG.md exists, auto-generate
   an entry from branch commits and diff.

9. **Commit.** Follow Step 7: bisectable commits, stage files individually.

10. **Push and create PR.** Follow Steps 8-9: push with `-u`, create PR via
    `gh pr create` with Summary + Test plan body.

11. **Update state.** Follow Step 10: update `todo.md` with PR URL.

## Relationship to /q:finish
- `/q:ship` is the full PR pipeline (test, review, version, changelog, PR).
- `/q:finish` is branch cleanup (verify, then merge/PR/keep/discard options).
- Use `/q:ship` when you want to create a PR. Use `/q:finish` when the branch
  work is done and you want to decide what to do with it.

## Success Criteria
- Not on base branch
- Tests pass (in-branch failures fixed or blocking)
- Diff reviewed for critical issues
- PR created with structured body (Summary + Test plan)
- `todo.md` updated with PR reference
