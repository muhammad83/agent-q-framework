---
name: q:docs
description: Sync project documentation with shipped code changes
triggers: [docs, document, update docs, sync docs, post-ship docs, document release]
argument-hint: "[optional: base branch, default auto-detected]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
autonomy: confirm
namespace: dx
---

## Objective
Sync all project documentation with what actually shipped. Reads every doc file,
cross-references the git diff, updates stale sections, polishes CHANGELOG voice,
and checks cross-doc consistency.

## Execution Context
- Read `workflows/document-release.md` for the full workflow definition
- Read `context/rules.md` for commit format
- Read `CLAUDE.md` for project context
- Read `todo.md` for current project state

## Process

1. **Detect base branch.** Follow Step 0 from `workflows/document-release.md`:
   check `gh pr view`, then `gh repo view`, then fall back to `main`.
   If an argument was provided, use that as the base branch.

2. **Pre-flight.** Follow Step 1: verify not on base branch, gather diff context,
   discover all documentation files, classify the changes.

3. **Audit each doc file.** Follow Step 2: cross-reference each doc against the
   diff. Classify updates as auto-update (factual) or ask-user (narrative/risky).

4. **Apply auto-updates.** Follow Step 3: make factual corrections directly.
   Output a one-line summary for each file modified.

5. **Ask about risky changes.** Follow Step 4: present narrative/subjective changes
   to the user with recommendations.

6. **Polish CHANGELOG voice.** Follow Step 5: if CHANGELOG was modified on this
   branch, review for user-forward voice. Never delete or rewrite entries.

7. **Cross-doc consistency.** Follow Step 6: verify feature lists match across docs,
   check discoverability, fix factual inconsistencies.

8. **Commit and report.** Follow Step 7: stage files individually, commit, output
   doc health summary, update `todo.md`.

## When to run
- After `/q:ship` to ensure docs match the PR
- After merging a PR to sync docs with main
- When the user asks to "update the docs" or "sync documentation"
- Before a release to verify all docs are current

## Success Criteria
- All doc files cross-referenced against the diff
- Factual corrections applied automatically
- Risky changes presented to user for approval
- Cross-doc consistency verified
- Doc health summary output
- `todo.md` updated
