# Orchestration Protocol

## Purpose
Defines how agents hand off work, chain together, and produce verdicts in the
Agent Q multi-agent pipeline.

## Agent Chain

The standard pipeline is sequential with a document review gate and an
optional debug loop:

```
q-planner --> [document review] --> q-executor --> q-verifier --+--> SHIP
                  |                                             |
                  +--> REVISE (up to 3x)                        +--> q-debugger --> q-verifier (retry)
                  |                                             |
                  +--> surface to human                         +--> BLOCKED
```

**Order:** q-planner -> document review -> q-executor -> q-verifier -> q-debugger (if needed)

Each agent reads its role file from `agents/q-{role}.md` before starting work.

## Specialist Routing

Specialist agents advise alongside the core pipeline agents. They are loaded as
advisors when keyword or file triggers match -- they do not replace pipeline agents.

### Routing Table

| Specialist | Keyword Triggers | File Triggers | Priority |
|------------|-----------------|---------------|----------|
| **q-security** | vulnerability, XSS, auth, OWASP, injection, CVE, security, CSRF, SQL injection, encryption, secrets, permissions | `*.env`, `auth/*`, `middleware/*`, `security/*` | 1 (highest) |
| **q-frontend** | UI, CSS, component, layout, responsive, accessibility, a11y, Tailwind, React, animation, design system | `*.tsx`, `*.css`, `*.scss`, `components/*`, `pages/*`, `layouts/*` | 2 |
| **q-researcher** | research, compare, evaluate, alternatives, best practice, benchmark, trade-off, library choice, architecture decision | _(no file triggers)_ | 3 (lowest) |

### Priority Order

When multiple specialists match the same task, load them in priority order:
**security > frontend > researcher**. Security always takes precedence because
vulnerabilities are the highest-risk category.

### Invocation Rules

1. **Advisor, not replacement.** Specialists are loaded alongside the active
   pipeline agent (executor, verifier, etc.), not instead of it.
2. **Trigger matching.** A specialist is invoked when the task description or
   modified files match its keyword or file triggers.
3. **No match = no specialist.** If no triggers match, no specialist is loaded.
   Do not force-load a specialist without a trigger match.
4. **Multiple specialists allowed.** If both security and frontend triggers
   match, both specialists advise (in priority order).
5. **Read-only parallel.** Specialists can run in parallel with pipeline agents
   when both are read-only (e.g., security review + verifier review).
6. **Output integration.** Specialist findings are included in the pipeline
   agent's handoff report under a "Specialist Findings" subsection.

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

## Document Review Loop

After the planner produces a build plan and before execution begins, the plan
passes through a document review gate. A subagent reviewer evaluates the plan
for quality before it reaches the executor.

### Review Criteria

The reviewer evaluates three dimensions:

1. **Completeness** -- Are all requirements from the user's request addressed?
   Are there tasks for every file that needs to change? Are edge cases covered?

2. **Feasibility** -- Can each task be done in the stated scope? Are there
   hidden dependencies? Is the task breakdown realistic?

3. **Risks** -- Are there gaps, ambiguities, or contradictions in the plan?
   Are there implicit assumptions that should be made explicit?

### Review Verdict

- **APPROVED** -- Plan is ready for execution. Proceed to q-executor.
- **REVISE** -- Plan needs changes. Reviewer provides specific feedback
  (what to fix, why, and where). Planner revises and resubmits.

### Iteration Cap

The review loop is capped at **3 iterations**.

```
Iteration 1: reviewer evaluates -> REVISE -> planner revises
Iteration 2: reviewer evaluates -> REVISE -> planner revises
Iteration 3: reviewer evaluates -> REVISE -> surface to human
```

After 3 REVISE verdicts without reaching APPROVED, the orchestrator:
1. Presents the plan in its current state to the human.
2. Lists all unresolved reviewer concerns.
3. Asks the human to approve as-is, provide guidance, or cancel.

### Review Handoff Format

```
## REVIEW: plan-reviewer
### Verdict
APPROVED / REVISE
### Iteration
{n}/3
### Completeness
{assessment}
### Feasibility
{assessment}
### Risks
{assessment}
### Feedback (if REVISE)
- {specific change 1}
- {specific change 2}
```

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
