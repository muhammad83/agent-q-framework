---
name: q:quick
description: Apply a small, focused fix without full planning overhead
triggers: [quick fix, small change, patch, tweak]
argument-hint: "[what to fix — be specific]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
autonomy: confirm
namespace: execution
---

## Objective
Make a small, focused change without the full planning protocol. For single-file
fixes, bug patches, typo corrections, and trivial edits.

## Execution Context
- Read `context/rules.md` for deviation rules and atomic commits
- Read `todo.md` for current state

## Process

1. **Assess scope.** The fix should be:
   - 1-2 files max
   - No architectural changes
   - No new dependencies
   - If it's bigger than this, use `/q:plan` instead

2. **Read the relevant code.** Understand what you're changing before touching it.

3. **Make the fix.** Apply the change directly.

4. **Verify.** Run tests if they exist. Check that nothing else broke.

5. **Commit.** Stage files individually and commit:
   `fix({scope}): {description}`

6. **Update todo.md** if the fix relates to a known issue or active task.

## Success Criteria
- Fix applied in 1-2 files
- Tests pass (if they exist)
- Committed with proper format
- No side effects introduced
