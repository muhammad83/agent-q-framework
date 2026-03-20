## Objective
Run the full Agent Q multi-agent pipeline on a feature or task, chaining
q-planner → q-executor → q-verifier → q-debugger with structured handoffs.

## Input
Feature or task description: $ARGUMENTS

## Execution Context
- Read `workflows/orchestration-protocol.md` for the full protocol
- Read `context/rules.md` for coding standards
- Read `todo.md` for current project state

## Process

1. **Load protocol.** Read `workflows/orchestration-protocol.md`. This defines
   handoff format, verdict rules, parallel logic, and debug loop limits.

2. **Phase 1 — Plan.** Read `agents/q-planner.md` for the planner role.
   Spawn a planner subagent (Agent tool, subagent_type: "Plan") with the feature
   description. The planner produces a build plan with tasks, file list, and
   edge cases. Capture the output as HANDOFF: q-planner → q-executor.

3. **Confirm plan with user.** Present the plan summary. Ask the user to
   approve, adjust, or reject before proceeding.

4. **Phase 2 — Execute.** Read `agents/q-executor.md` for the executor role.
   Spawn an executor subagent (Agent tool) with the plan handoff.
   - If the plan has independent tasks, spawn multiple executors in parallel.
   - Each executor works on its assigned tasks and returns a handoff document.
   - Collect all executor handoffs into HANDOFF: q-executor → q-verifier.

5. **Phase 3 — Verify.** Read `agents/q-verifier.md` for the verifier role.
   Spawn a verifier subagent (Agent tool) with the executor handoff.
   Run these in parallel where possible:
   - q-verifier (code quality, logic, tests)
   - Security scan (if `tools/security-scan.cjs` exists, run it on modified files)
   Collect results and assign a verdict: **SHIP**, **NEEDS WORK**, or **BLOCKED**.

6. **Phase 4 — Debug (if NEEDS WORK).** Read `agents/q-debugger.md` for the
   debugger role. Spawn a debugger subagent with the verifier's findings.
   After the debugger finishes, re-run Phase 3 (q-verifier).
   - **Max 2 debug→verify cycles.** After 2 attempts, verdict = BLOCKED.

7. **Report.** Produce the orchestration report (format in the protocol).
   Update `todo.md` with results.

## Verdict Rules
- **SHIP** — Zero critical or major issues. Commit and report success.
- **NEEDS WORK** — Major issues found but fixable. Route to debugger.
- **BLOCKED** — Critical issues, architectural problems, or debug loop exhausted.
  Stop and present all findings to the user.

## Handoff Format
```
## HANDOFF: [previous-agent] → [next-agent]
### Context
### Findings
### Files Modified
### Open Questions
### Recommendations
```
Max 50 lines per handoff. Summarize ruthlessly.

## Success Criteria
- All pipeline phases completed or explicitly blocked
- Orchestration report produced with clear verdict
- todo.md updated with results
- All modified files listed in the report
