---
name: q:verify
description: Verify completed work against the build plan and quality standards
triggers: [verify, check, validate, test, quality check]
argument-hint: "[build-plan filename or feature name]"
allowed-tools: [Read, Bash, Glob, Grep]
autonomy: auto
namespace: quality
---

## Objective
Verify that completed work matches the build plan, passes tests, and meets
quality standards. This is the "Opus verification" step from the Spin Jit Su workflow.

## Execution Context
- Read `context/rules.md` for verification rules
- Read `context/engineering-preferences.md` for quality standards
- Read the relevant `workflows/build-plan-{feature}.md`

## Process

1. **Load plan.** Read the build plan that was executed.

2. **Check completeness.** For every task in the plan:
   - Was it completed?
   - Were all specified files created/modified?
   - Does the implementation match what was planned?

3. **Run tests.** Execute any existing test suites (`pytest`, `ruff check`,
   `npm test`, etc.). Report failures.

4. **Run verify.sh.** If the task produced output files, run
   `./tools/verify.sh <filepath>`. Fix any failures.

5. **Code review.** Scan all modified files for:
   - Bugs and logic errors
   - Security issues (OWASP top 10)
   - Missing edge cases
   - Deviations from the build plan
   - Hardcoded secrets or API keys

6. **Report.** Present a numbered list:
   - Issues found (with severity: critical/major/minor)
   - Deviations from plan
   - Missing tests
   - Suggestions for improvement

7. **Update todo.md** with verification results.

## Success Criteria
- Every plan task verified as complete
- All tests pass
- No critical or major issues found (or all are documented)
- `todo.md` updated with verification status
