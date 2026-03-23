---
name: q:orchestrate
description: Run the full Agent Q multi-agent pipeline on a feature or task
triggers: [orchestrate, pipeline, full build, end to end]
argument-hint: "[feature or task description]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
autonomy: confirm
namespace: execution
---

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

2. **Phase 1 -- Plan.** Read `agents/q-planner.md` for the planner role.
   Spawn a planner subagent (Agent tool, subagent_type: "Plan") with the feature
   description. The planner produces a build plan with tasks, file list, and
   edge cases.

3. **Phase 1.5 -- Document Review.** Run the document review loop from
   `workflows/orchestration-protocol.md`:
   a. Evaluate the plan for completeness, feasibility, and risks.
   b. If verdict is REVISE, feed specific feedback back to the planner
      and have it revise the plan. Re-evaluate.
   c. Cap at 3 iterations. After 3 REVISE verdicts without APPROVED,
      surface all unresolved concerns to the human and ask for approval.
   d. Once APPROVED (or human-approved), capture the final plan as
      HANDOFF: q-planner -> q-executor.

4. **Confirm plan with user.** Present the reviewed plan summary and the
   reviewer's verdict. Ask the user to approve, adjust, or reject before
   proceeding.

5. **Phase 2 -- Execute.** Read `agents/q-executor.md` for the executor role.
   Spawn an executor subagent (Agent tool) with the plan handoff.
   - If the plan has independent tasks, spawn multiple executors in parallel.
   - Each executor works on its assigned tasks and returns a handoff document.
   - Collect all executor handoffs into HANDOFF: q-executor -> q-verifier.

6. **Phase 3 -- Verify.** Read `agents/q-verifier.md` for the verifier role.
   Spawn a verifier subagent (Agent tool) with the executor handoff.
   Run these in parallel where possible:
   - q-verifier (two-stage review: spec compliance + code quality)
   - Security scan (if `tools/security-scan.cjs` exists, run it on modified files)
   Collect results and assign a verdict: **SHIP**, **NEEDS WORK**, or **BLOCKED**.

7. **Phase 4 -- Debug (if NEEDS WORK).** Read `agents/q-debugger.md` for the
   debugger role. Spawn a debugger subagent with the verifier's findings.
   After the debugger finishes, re-run Phase 3 (q-verifier).
   - **Max 2 debug->verify cycles.** After 2 attempts, verdict = BLOCKED.

8. **Report.** Produce the orchestration report (format in the protocol).
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
