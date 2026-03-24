---
name: review-eng
description: >
  Engineering manager-mode plan review. Lock in the execution plan —
  architecture, data flow, error maps, security, test coverage, performance,
  observability, deployment. This is the required shipping gate. A plan must
  pass eng review before implementation begins.
autonomy: interactive
namespace: review
triggers:
  - user asks for "eng review", "architecture review", "lock in the plan"
  - plan is ready for implementation and needs a final engineering gate
  - user is about to start coding a multi-file change
---

# Workflow: Engineering Plan Review

**This is the required shipping gate.** Every plan must pass an engineering
review before implementation. Other reviews (CEO, design, PR) are optional.

## Trigger
Run this when a plan needs engineering sign-off before implementation, or when
the user asks for architecture review, test coverage analysis, or performance
review of a plan.

## Context Needed
Before running, make sure you have:
- [ ] The plan file to review (e.g., `workflows/build-plan-{feature}.md`)
- [ ] `todo.md` for current project state
- [ ] `context/rules.md` for review standards
- [ ] `context/engineering-preferences.md` if it exists
- [ ] `agents/q-reviewer.md` for report format and severity levels

## Steps

### Step 0: Scope Challenge
Before reviewing anything, answer these questions:

1. **Existing code leverage:** What existing code already partially or fully
   solves each sub-problem? Can we reuse rather than rebuild?
2. **Minimum changes:** What is the minimum set of changes to achieve the goal?
   Flag any work that could be deferred.
3. **Complexity check:** If the plan touches 8+ files or introduces 2+ new
   classes/services, challenge whether the same goal can be achieved with fewer
   moving parts.
4. **Search check:** For each architectural pattern or infrastructure component:
   - Does the framework have a built-in?
   - Is the approach current best practice?
   - Are there known pitfalls?
5. **todo.md cross-reference:** Are deferred items blocking this plan? Can any
   be bundled without expanding scope?
6. **Completeness check:** Is the plan doing the complete version or a shortcut?
   If the shortcut saves minimal time, recommend the complete version.
7. **Distribution check:** If the plan introduces a new artifact (CLI, library,
   container), does it include the build/publish pipeline?

If the complexity check triggers, recommend scope reduction. Once the user
accepts or rejects, commit fully — do not re-argue in later sections.

### Section 1: Architecture Review
Evaluate and diagram:

- **System design and component boundaries.** Draw the dependency graph.
- **Data flow — all four paths.** For every new data flow, diagram:
  - Happy path (data flows correctly)
  - Nil path (input is nil/missing)
  - Empty path (input present but empty/zero-length)
  - Error path (upstream call fails)
- **State machines.** Diagram every new stateful object. Include invalid
  transitions and what prevents them.
- **Coupling.** Which components are now coupled that were not before? Is
  the coupling justified? Show before/after dependency graph.
- **Scaling.** What breaks first under 10x load? Under 100x?
- **Single points of failure.** Map them.
- **Security architecture.** Auth boundaries, data access, API surfaces. For
  each new endpoint: who can call it, what do they get, what can they change?
- **Production failure scenarios.** For each new integration point, describe one
  realistic failure (timeout, cascade, data corruption) and whether the plan
  accounts for it.
- **Rollback posture.** If this ships and breaks, what is the rollback procedure?

### Section 2: Error & Rescue Map
For every new method, service, or codepath that can fail, fill in this table:

```
METHOD/CODEPATH          | WHAT CAN GO WRONG           | EXCEPTION CLASS
-------------------------|-----------------------------|-----------------
ExampleService#call      | API timeout                 | TimeoutError
                         | API returns 429             | RateLimitError
                         | Malformed JSON response     | JSONParseError
                         | DB connection pool exhausted| ConnectionPoolExhausted
                         | Record not found            | RecordNotFound
-------------------------|-----------------------------|-----------------

EXCEPTION CLASS              | RESCUED?  | RESCUE ACTION          | USER SEES
-----------------------------|-----------|------------------------|------------------
TimeoutError                 | Y         | Retry 2x, then raise   | "Temporarily unavailable"
RateLimitError               | Y         | Backoff + retry         | Nothing (transparent)
JSONParseError               | N <- GAP  | --                     | 500 error <- BAD
ConnectionPoolExhausted      | N <- GAP  | --                     | 500 error <- BAD
RecordNotFound               | Y         | Return nil, log warning | "Not found" message
```

Rules:
- Catch-all error handling is ALWAYS a smell. Name specific exceptions.
- Every rescued error must either: retry with backoff, degrade gracefully with
  a user-visible message, or re-raise with added context.
- "Swallow and continue" is almost never acceptable.
- For each GAP: specify the rescue action and what the user should see.

### Section 3: Security & Threat Model
Evaluate:

- **Attack surface expansion.** New endpoints, params, file paths, background jobs.
- **Input validation.** For every new user input: validated? Sanitized? Rejected
  loudly on failure? Test with: nil, empty, wrong type, max length, unicode,
  HTML/script injection.
- **Authorization.** For every new data access: scoped to right user/role? Direct
  object reference vulnerability?
- **Secrets and credentials.** New secrets in env vars, not hardcoded? Rotatable?
- **Dependency risk.** New packages? Security track record?
- **Data classification.** PII, payment data, credentials? Handling consistent?
- **Injection vectors.** SQL, command, template, LLM prompt injection — check all.
- **Audit logging.** Sensitive operations: is there an audit trail?

For each finding: threat, likelihood (High/Med/Low), impact (High/Med/Low),
and whether the plan mitigates it.

### Section 4: Test Coverage Diagram
100% coverage is the goal. Evaluate every codepath in the plan.

**Step 1 — Trace every codepath:**
For each new component, follow the execution through every branch:
- Where does input come from?
- What transforms it?
- Where does it go?
- What can go wrong at each step?

Diagram showing: every function added/modified, every conditional branch,
every error path, every call to another function, every edge case.

**Step 2 — Map user flows and interactions:**
- User flows: sequence of actions touching this code.
- Interaction edge cases: double-click, navigate-away, stale data, slow
  connection, concurrent actions.
- Error states: what does the user experience for each error?
- Boundary states: zero results, 10,000 results, max-length input.

**Step 3 — Check coverage against existing tests:**
For each branch, search for a test. Quality scoring:
- 3 stars: tests behavior with edge cases AND error paths
- 2 stars: tests correct behavior, happy path only
- 1 star: smoke test / existence check / trivial assertion

**Test type decision matrix:**
- E2E: user flows spanning 3+ components, integration points, auth/payment flows.
- Eval: critical LLM calls, prompt template changes.
- Unit: pure functions, internal helpers, single-function edge cases.

**Regression rule (mandatory):** When a diff modifies existing behavior and the
test suite does not cover the changed path, a regression test is CRITICAL — no
skipping, no asking. Regressions are highest-priority tests.

**Step 4 — Output ASCII coverage diagram:**
```
CODE PATH COVERAGE
===========================
[+] src/services/billing.ts
    |-- processPayment()
    |   |-- [3-star TESTED] Happy path + error — billing.test.ts:42
    |   |-- [GAP]           Network timeout — NO TEST
    |   +-- [GAP]           Invalid currency — NO TEST
    +-- refundPayment()
        |-- [2-star TESTED] Full refund — billing.test.ts:89
        +-- [1-star TESTED] Partial refund — billing.test.ts:101

COVERAGE: 3/5 paths tested (60%)
GAPS: 2 paths need tests
```

**Step 5 — Add missing tests to the plan** with specific test files, assertions,
and whether each is unit/E2E/eval.

### Section 5: Performance Review
Evaluate:

- **N+1 queries.** For every new data traversal: is there eager loading?
- **Memory usage.** For every new data structure: max size in production?
- **Database indexes.** For every new query: is there an index?
- **Caching opportunities.** Expensive computation or external calls?
- **Background job sizing.** Worst-case payload, runtime, retry behavior?
- **Slow paths.** Top 3 slowest new codepaths and estimated p99 latency.
- **Connection pool pressure.** New DB/Redis/HTTP connections?

### Section 6: Observability & Debuggability Review
Evaluate:

- **Logging.** Structured logs at entry, exit, and significant branches?
- **Metrics.** What metric tells you it is working? What tells you it is broken?
- **Tracing.** Cross-service flows: trace IDs propagated?
- **Alerting.** What new alerts should exist?
- **Dashboards.** What panels do you want on day 1?
- **Debuggability.** If a bug is reported 3 weeks post-ship, can you reconstruct
  what happened from logs alone?
- **Runbooks.** For each new failure mode: what is the operational response?

### Section 7: Deployment & Rollout Review
Evaluate:

- **Migration safety.** Backward-compatible? Zero-downtime? Table locks?
- **Feature flags.** Should any part be behind a flag?
- **Rollout order.** Correct sequence: migrate first, deploy second?
- **Rollback plan.** Explicit step-by-step.
- **Deploy-time risk.** Old code and new code running simultaneously — what breaks?
- **Post-deploy verification.** First 5 minutes? First hour?

### Section 8: Failure Modes Registry
For each new codepath from the test coverage diagram, list one realistic failure
and evaluate:

| Codepath | Failure Mode | Test? | Error Handling? | User Sees? |
|----------|-------------|-------|-----------------|------------|
| ... | timeout | Y/N | Y/N | clear error / silent |

If any failure has NO test AND NO handling AND is silent = **CRITICAL GAP**.

### Required Outputs
After all sections are reviewed, produce:

1. **"NOT in scope" section** — work considered and explicitly deferred.
2. **"What already exists" section** — existing code the plan should reuse.
3. **todo.md updates** — present each TODO individually with: what, why, pros,
   cons, context, dependencies. Options: A) Add, B) Skip, C) Build now.
4. **Diagrams** — ASCII diagrams for any non-trivial data flow, state machine,
   or processing pipeline in the plan.
5. **Completion summary** using q-reviewer.md report format.

## Tools Used
- File reading tools for plan and codebase inspection
- Git commands for branch context and history
- Search tools for existing code and test coverage analysis

## Output
- Structured review report (format defined in `agents/q-reviewer.md`)
- Updated plan file with review findings
- Updated `todo.md` with deferred items and review status
- ASCII coverage diagram

## Success Criteria
- Scope challenge completed — existing code leverage mapped
- All 8 sections evaluated (architecture, error map, security, tests,
  performance, observability, deployment, failure modes)
- Error/rescue map has no unresolved GAPs at CRITICAL level
- Test coverage diagram produced with gap analysis
- Failure modes registry produced — no silent CRITICAL GAPs
- "NOT in scope" and "What already exists" sections written
- Structured report produced with PASS / PASS WITH WARNINGS / FAIL verdict

## Edge Cases
- Plan is too complex for single session: prioritize Step 0 > Test Diagram >
  Error/Rescue Map > Failure Modes > everything else. Never skip Step 0.
- Plan has no UI scope: skip frontend-specific checks.
- Existing tests are flaky: note flakiness as a WARNING, do not count flaky
  tests as coverage.
- Plan introduces new infrastructure: verify it is spending an "innovation token"
  wisely — boring technology is the default.
