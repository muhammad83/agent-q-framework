# Orchestration Protocol

## Purpose
Defines how agents hand off work, chain together, and produce verdicts in the
Agent Q multi-agent pipeline.

## Agent Chain

The standard pipeline is sequential with an optional debug loop:

```
q-planner --> q-executor --> q-verifier --+--> SHIP
                                          |
                                          +--> q-debugger --> q-verifier (retry)
                                          |
                                          +--> BLOCKED
```

**Order:** q-planner -> q-executor -> q-verifier -> q-debugger (if needed)

Each agent reads its role file from `agents/q-{role}.md` before starting work.

## Handoff Format

Every agent-to-agent handoff uses this structure (max 50 lines, summarize ruthlessly):

```
## HANDOFF: [previous-agent] → [next-agent]
### Status
`pending` | `running` | `done` | `failed`
### Timestamps
- Started: [ISO timestamp]
- Completed: [ISO timestamp]
### Context
[Brief description of what was done]
### Findings
[Key results or issues discovered]
### Files Modified
[List of files]
### Error Classification (if failed)
[Error type from taxonomy: BuildError/LogicError/ArchitecturalError/EnvironmentError]
### Open Questions
[Unresolved items]
### Recommendations
[Suggested next steps]
```

### Handoff Rules
- Keep handoffs under 50 lines. Summarize ruthlessly.
- Include file paths, never vague references like "the main file."
- Open Questions must be answerable by the next agent or flagged for the user.
- If a handoff exceeds 50 lines, trim Findings to top-5 most important items.

## Status Polling

The orchestrator checks handoff status after each phase:
- If `done` → proceed to next phase
- If `failed` + BuildError or LogicError → route to q-debugger
- If `failed` + ArchitecturalError → verdict = **BLOCKED**, present to user
- If `failed` + EnvironmentError → retry once, then BLOCKED

## Parallel vs Sequential Logic

### Sequential (default)
Agents that depend on the previous agent's output run sequentially:
- q-planner must finish before q-executor starts (executor needs the plan).
- q-executor must finish before q-verifier starts (verifier needs the code).
- q-debugger must finish before q-verifier retries (verifier needs the fix).

### Parallel (when independent)
Agents or checks that do not depend on each other run in parallel:
- q-verifier + security scan (both read the same code, neither modifies it).
- q-verifier + lint check.
- Multiple q-executor agents on independent tasks within a build plan.
- Multiple q-verifier agents checking different subsystems.

**Rule:** If two agents both only READ the same files and neither writes,
they can run in parallel. If either writes, they must run sequentially.

## Verdict System

After the q-verifier completes, the orchestrator assigns a verdict:

| Verdict | Meaning | Next Step |
|---------|---------|-----------|
| **SHIP** | All checks pass, no critical/major issues | Done. Report success. |
| **NEEDS WORK** | Minor issues found, fixable by debugger | Route to q-debugger, then re-verify. |
| **BLOCKED** | Critical issues, architectural problems, or debug loop exhausted | Stop. Report to user with details. |

### Verdict Rules
- **SHIP** — Zero critical or major issues. Commit and report success.
- **NEEDS WORK** — Major issues found but fixable. Route to debugger.
- **BLOCKED** — Critical issues, architectural problems, or debug loop exhausted (max 2 cycles).

## Debug Loop Limit

The debugger -> verifier retry loop is capped at **2 attempts**.

```
Attempt 1: q-debugger fixes issues -> q-verifier re-checks
Attempt 2: q-debugger fixes remaining -> q-verifier re-checks
Attempt 3: DOES NOT HAPPEN. Verdict = BLOCKED.
```

After 2 failed attempts, the orchestrator:
1. Collects all debug files and verifier reports.
2. Sets verdict to BLOCKED.
3. Presents the user with a summary of what was tried and what remains broken.

## Orchestration Report Format

The final output of any orchestration run:

```
ORCHESTRATION REPORT
====================
Feature: {feature name}
Plan: {plan file path}
Verdict: SHIP / NEEDS WORK / BLOCKED

Pipeline:
  [1] q-planner    ... DONE
  [2] q-executor   ... DONE
  [3] q-verifier   ... DONE (issues: 0 critical, 1 major, 2 minor)
  [4] q-debugger   ... DONE (attempt 1/2)
  [5] q-verifier   ... DONE (re-check: all clear)

Files Modified:
  - path/to/file1.ts (created)
  - path/to/file2.ts (modified)

Issues Resolved:
  - [MAJOR] Description of fixed issue

Remaining Issues:
  - [MINOR] Description (non-blocking)

Recommendations:
  - Any follow-up work suggested
```
