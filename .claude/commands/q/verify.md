---
name: q:verify
description: Verify completed work with two-stage review (spec compliance + code quality)
triggers: [verify, check, validate, test, quality check]
argument-hint: "[build-plan filename or feature name] [--quick]"
allowed-tools: [Read, Bash, Glob, Grep]
autonomy: auto
namespace: quality
---

## Objective
Verify that completed work matches the build plan and meets quality standards
using a two-stage review process. See `agents/q-verifier.md` for the full
two-stage protocol.

## Flags
- `--quick` -- Run a single combined pass instead of two stages. Use for
  trivial changes (typo fixes, config tweaks, single-line edits).

## Execution Context
- Read `agents/q-verifier.md` for the two-stage review protocol
- Read `context/rules.md` for verification rules
- Read `context/engineering-preferences.md` for quality standards
- Read the relevant `workflows/build-plan-{feature}.md`

## Process

### Standard Mode (default -- two stages)

1. **Load plan.** Read the build plan that was executed.

2. **Run tests.** Execute any existing test suites (`pytest`, `ruff check`,
   `npm test`, etc.). Report failures.

3. **Run verify.sh.** If the task produced output files, run
   `./tools/verify.sh <filepath>`. Fix any failures.

4. **Pass 1 -- Spec Compliance.** For every task in the plan:
   - Was it completed?
   - Were all specified files created/modified?
   - Does the implementation match what was planned?
   - Are edge cases from the plan handled?
   - Verdict: COMPLIANT or DEVIATION FOUND (list each deviation)

5. **Pass 2 -- Code Quality.** Scan all modified files for:
   - Architecture and separation of concerns
   - DRY violations
   - Edge cases and error handling
   - Security issues (OWASP top 10, hardcoded secrets)
   - Performance concerns (N+1, memory leaks)
   - Test coverage and quality
   - Verdict: CLEAN or ISSUES FOUND (list each issue)

6. **Report.** Produce the two-stage verification report (format in
   `agents/q-verifier.md`). Include both pass verdicts and an overall status.

7. **Update todo.md** with verification results.

### Quick Mode (--quick flag)

1. **Load plan.** Read the build plan that was executed.

2. **Run tests.** Execute any existing test suites. Report failures.

3. **Single pass.** Combine spec compliance and code quality into one check.
   Verdict: PASS or FAIL.

4. **Report.** Produce the quick mode report (format in `agents/q-verifier.md`).

5. **Update todo.md** with verification results.

## Success Criteria
- Every plan task verified as complete
- All tests pass
- Both passes produce a verdict (or single verdict in quick mode)
- No critical or major issues found (or all are documented)
- `todo.md` updated with verification status
