---
name: q:qa
description: Run a code-level QA audit with interaction state mapping and health score
triggers: [qa, quality, audit, test coverage, code qa]
argument-hint: "[optional: --quick|--exhaustive] [optional: file paths or feature name]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
autonomy: auto
namespace: quality
---

## Objective
Run a structured code-level QA audit: interaction state coverage map, edge case
matrix, error path coverage, input validation audit, and health score. Produces
a structured report. Does NOT fix anything -- report only.

## Execution Context
- Read `workflows/qa.md` for the full workflow definition
- Read `context/rules.md` for verification conventions
- Read `CLAUDE.md` for project context
- Read `todo.md` for known issues

## Process

1. **Detect mode.** Parse argument for `--quick` or `--exhaustive`. Default: Standard.

2. **Detect scope.** Follow Step 0 from `workflows/qa.md`:
   - On a feature branch with no scope: diff-aware mode (audit changed files).
   - Specific files/feature given: scope to those.
   - On main or no diff: ask for scope or audit full codebase.

3. **Build interaction state coverage map.** Follow Step 1: for each feature in
   scope, map Loading/Empty/Error/Success/Partial states as Handled/Missing/Partial.

4. **Build edge case matrix.** Follow Step 2: for each function in scope, identify
   boundary values, null inputs, concurrent access, type mismatches, etc.

5. **Trace error paths.** Follow Step 3: find all error origins, trace propagation,
   classify as Handled well/Handled poorly/Unhandled.

6. **Audit input validation.** Follow Step 4: check server-side validation,
   completeness, and user-friendly error messages for all user-facing inputs.

7. **Compute health score.** Follow Step 5: weighted average across categories.

8. **Generate report.** Follow Step 6: write structured report to
   `qa-report-{branch}-{YYYY-MM-DD}.md`.

9. **Update state.** Update `todo.md` with QA results.

## Relationship to gstack /qa
- `/q:qa` is code-level analysis (reads source, traces logic, no browser).
- gstack `/qa` is browser-based testing (navigates pages, clicks buttons, takes screenshots).
- They complement each other. Use `/q:qa` for code coverage, use gstack `/qa` for UI testing.

## Success Criteria
- Coverage map built for all in-scope features
- Edge case matrix populated
- Error paths traced and classified
- Health score computed with category breakdown
- Structured report generated
- Top 3 issues prioritized
