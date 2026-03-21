---
name: q:review
description: Run a structured code review on recent changes or a full codebase
triggers: [review, code review, audit, inspect]
argument-hint: "[file, directory, or 'all' for full codebase]"
allowed-tools: [Read, Glob, Grep, Bash]
autonomy: auto
namespace: quality
---

## Objective
Perform a structured 4-section code review following the Phase 2B workflow.

## Execution Context
- Read `workflows/code-review.md` for the full review process
- Read `context/engineering-preferences.md` for quality standards
- Read `context/rules.md` for verification conventions

## Process

1. **Determine scope.** If argument is a file or directory, review that.
   If "all" or no argument, review the entire codebase.

2. **Check change size.** Count files/lines changed:
   - BIG CHANGE (50+ lines, 3+ files): 4 issues per section
   - SMALL CHANGE: 1 issue per section

3. **Review in 4 sections:**

   **Architecture:**
   - File organization, separation of concerns
   - Dependency management, circular imports
   - API design, data flow

   **Code Quality:**
   - DRY violations, naming, readability
   - Error handling, edge cases
   - Security (injection, XSS, secrets in code)

   **Tests:**
   - Coverage gaps, missing edge case tests
   - Test quality (testing behavior, not implementation)
   - Flaky test risks

   **Performance:**
   - N+1 queries, unnecessary re-renders
   - Memory leaks, large payloads
   - Caching opportunities

4. **Present findings** as a numbered list per section with severity.

5. **Offer to fix.** Ask: "Want me to fix these? All, or specific numbers?"

## Success Criteria
- All 4 sections reviewed
- Issues numbered with severity
- Actionable fix suggestions for each issue
- User can approve/reject individual fixes
