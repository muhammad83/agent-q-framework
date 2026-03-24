---
name: review-ceo
description: >
  CEO/founder-mode plan review. Challenge premises, find the 10-star version,
  map the dream state, evaluate implementation alternatives, and select the
  right scope mode. Four modes: EXPANSION (dream big), SELECTIVE EXPANSION
  (hold scope + cherry-pick), HOLD SCOPE (maximum rigor), REDUCTION (strip
  to essentials).
autonomy: interactive
namespace: review
triggers:
  - user asks for a "CEO review", "strategy review", "scope review"
  - user says "think bigger", "expand scope", "rethink this", "is this ambitious enough"
  - plan feels under-scoped for the opportunity
---

# Workflow: CEO Plan Review

## Trigger
Run this when the user requests a strategic/scope review of a plan, or when a
plan would benefit from premise-challenging and scope evaluation before
implementation.

## Context Needed
Before running, make sure you have:
- [ ] The plan file to review (e.g., `workflows/build-plan-{feature}.md`)
- [ ] `todo.md` for current project state
- [ ] `context/rules.md` for review standards
- [ ] `context/engineering-preferences.md` if it exists
- [ ] `agents/q-reviewer.md` for report format and severity levels

## Philosophy

You are not rubber-stamping this plan. Your posture depends on the selected mode,
but in ALL modes: the user is 100% in control. Every scope change is an explicit
opt-in. Never silently add or remove scope.

### Prime Directives
1. Zero silent failures — every failure mode must be visible.
2. Every error has a name — not "handle errors" but specific exception classes.
3. Data flows have shadow paths — happy path, nil, empty, error for every flow.
4. Observability is scope, not afterthought.
5. Diagrams are mandatory for non-trivial flows.
6. Everything deferred must be written down.
7. Optimize for the 6-month future, not just today.
8. You have permission to say "scrap it and do this instead."

## Steps

### Step 1: System Audit (pre-review context gathering)
Before reviewing the plan, gather context:
1. Read the plan file.
2. Read todo.md and any architecture docs.
3. Check recent git history for the branch.
4. Check for TODOs/FIXMEs in files the plan touches.
5. Identify recently-touched files for hot-spot awareness.
6. Detect if plan has UI scope (for later design recommendations).

Report findings before proceeding.

### Step 2: Premise Challenge (3 Questions)
Challenge the plan's fundamental assumptions:

1. **Is this the right problem to solve?** Could a different framing yield a
   dramatically simpler or more impactful solution?
2. **What is the actual user/business outcome?** Is the plan the most direct
   path to that outcome, or is it solving a proxy problem?
3. **What would happen if we did nothing?** Real pain point or hypothetical one?

Ask the user about each question. If the user cannot articulate the problem or
keeps changing the problem statement, suggest they need more discovery before
a review is appropriate.

### Step 3: Existing Code Leverage
Map every sub-problem in the plan to existing code:

1. What existing code already partially or fully solves each sub-problem?
2. Can we capture outputs from existing flows rather than building parallel ones?
3. Is this plan rebuilding anything that already exists? If yes, explain why
   rebuilding is better than refactoring.

### Step 4: Dream State Mapping
Describe the ideal end state 12 months from now. Does this plan move toward
that state or away from it?

```
CURRENT STATE              THIS PLAN                12-MONTH IDEAL
[describe]        --->     [describe delta]  --->    [describe target]
```

### Step 5: Implementation Alternatives (MANDATORY)
Before selecting a mode, produce 2-3 distinct implementation approaches.
This is NOT optional — every plan must consider alternatives.

For each approach:
```
APPROACH A: [Name]
  Summary: [1-2 sentences]
  Effort:  [S/M/L/XL]
  Risk:    [Low/Med/High]
  Pros:    [2-3 bullets]
  Cons:    [2-3 bullets]
  Reuses:  [existing code/patterns leveraged]
```

Rules:
- At least 2 approaches required. 3 preferred for non-trivial plans.
- One approach must be the "minimal viable" (fewest files, smallest diff).
- One approach must be the "ideal architecture" (best long-term trajectory).
- If only one approach exists, explain concretely why alternatives were eliminated.
- State a recommendation with rationale before proceeding.
- Do NOT proceed to mode selection without user approval of the approach.

### Step 6: Mode Selection
Present four options to the user:

1. **SCOPE EXPANSION:** Dream big. Propose the ambitious version. Present each
   expansion individually for user approval.
   - Default for: greenfield features.
2. **SELECTIVE EXPANSION:** Hold current scope as baseline, but surface every
   expansion opportunity as individual opt-in decisions. Neutral recommendations.
   - Default for: feature enhancements, iterations on existing systems.
3. **HOLD SCOPE:** The scope is right. Make it bulletproof — architecture,
   security, edge cases, observability, deployment. No expansions surfaced.
   - Default for: bug fixes, hotfixes, refactors.
4. **SCOPE REDUCTION:** Find the minimum viable version. Cut everything else.
   - Suggest for: plans touching 15+ files unless user pushes back.

Once selected, commit fully. Do not silently drift toward a different mode.

### Step 7: Mode-Specific Analysis

**For SCOPE EXPANSION — run all, then the opt-in ceremony:**
1. **10x check:** What version is 10x more ambitious and delivers 10x more value
   for 2x the effort? Describe it concretely.
2. **Platonic ideal:** If the best engineer in the world had unlimited time and
   perfect taste, what would this system look like? What would the user feel?
3. **Delight opportunities:** What adjacent improvements would make this feature
   sing? List at least 5.
4. **Opt-in ceremony:** Present each concrete scope proposal individually.
   Options: A) Add to plan scope, B) Defer to todo.md, C) Skip.

**For SELECTIVE EXPANSION — hold scope, then surface expansions:**
1. Run complexity check (8+ files or 2+ new classes = smell).
2. Identify minimum changes to achieve the goal.
3. Then run expansion scan: 10x check, delight opportunities, platform potential.
4. **Cherry-pick ceremony:** Present each expansion individually with neutral
   recommendations. Options: A) Add to plan scope, B) Defer to todo.md, C) Skip.

**For HOLD SCOPE:**
1. Complexity check (8+ files or 2+ new classes = smell).
2. Minimum set of changes to achieve the goal.
3. Flag any deferrable work.

**For SCOPE REDUCTION:**
1. What is the absolute minimum that ships value? Everything else is deferred.
2. Separate "must ship together" from "nice to ship together."

### Step 8: Temporal Interrogation
Think ahead to implementation and surface decisions that should be resolved NOW:
```
HOUR 1 (foundations):    What does the implementer need to know?
HOUR 2-3 (core logic):  What ambiguities will they hit?
HOUR 4-5 (integration): What will surprise them?
HOUR 6+ (polish/tests): What will they wish they'd planned for?
```
Surface these as questions for the user now, not as "figure it out later."

### Step 9: Review Sections (after scope and mode are agreed)

Run each section. Ask the user about issues one at a time with recommendations.

1. **Architecture Review** — dependency graph, data flow (4 paths: happy/nil/empty/error),
   state machines, coupling, scaling, single points of failure, security architecture,
   production failure scenarios, rollback posture.
2. **Error & Rescue Map** — for every new codepath that can fail, fill in the table:
   ```
   METHOD/CODEPATH          | WHAT CAN GO WRONG        | EXCEPTION CLASS
   -------------------------|--------------------------|----------------
   ...
   EXCEPTION CLASS          | RESCUED? | RESCUE ACTION  | USER SEES
   -------------------------|----------|----------------|----------
   ...
   ```
3. **Security & Threat Model** — attack surface, input validation, authorization,
   secrets, dependency risk, data classification, injection vectors, audit logging.
4. **Data Flow & Interaction Edge Cases** — trace every new data flow through
   INPUT > VALIDATION > TRANSFORM > PERSIST > OUTPUT with shadow paths at each node.
   Map interaction edge cases (double-click, navigate-away, stale state, etc.).
5. **Code Quality** — DRY violations, naming, error handling patterns, complexity,
   over/under-engineering.
6. **Test Review** — diagram all new UX flows, data flows, codepaths, background
   jobs, integrations, error paths. For each: what test type, does it exist,
   happy/failure/edge cases?
7. **Performance** — N+1 queries, memory, indexes, caching, slow paths, connection pools.
8. **Observability** — logging, metrics, tracing, alerting, dashboards, debuggability,
   runbooks. (See also: review-eng.md for detailed treatment.)
9. **Deployment** — migration safety, feature flags, rollout order, rollback plan,
   deploy-time risk. (See also: review-eng.md for detailed treatment.)
10. **Long-Term Trajectory** — tech debt introduced, path dependency, reversibility,
    the 1-year question.
11. **Design & UX** (skip if no UI scope) — information architecture, interaction
    state coverage, user journey, responsive, a11y basics.

### Step 10: Required Outputs
After all sections are reviewed, produce:

1. **"NOT in scope" section** — work considered and explicitly deferred, with rationale.
2. **"What already exists" section** — existing code/flows that partially solve
   sub-problems and whether the plan reuses them.
3. **todo.md updates** — present each potential TODO individually with: what, why,
   pros, cons, context, dependencies. Options: A) Add to todo.md, B) Skip, C) Build now.
4. **Failure modes** — for each new codepath, one realistic failure and whether:
   a test covers it, error handling exists, the user sees a clear error or silent failure.
   If any has no test AND no handling AND would be silent = CRITICAL GAP.
5. **Completion summary** (see report format in agents/q-reviewer.md).

### Step 11: Update todo.md
Record review completion and any deferred items.

## Tools Used
- File reading tools for plan and codebase inspection
- Git commands for branch context and history
- Search tools for existing code leverage analysis

## Output
- Structured review report (format defined in `agents/q-reviewer.md`)
- Updated plan file with review findings
- Updated `todo.md` with deferred items and review status

## Success Criteria
- All 3 premise challenge questions answered
- Implementation alternatives produced and approach selected
- Mode selected and committed to
- All applicable review sections evaluated
- Structured report produced with severity ratings
- No CRITICAL GAPs left unresolved
- "NOT in scope" and "What already exists" sections written
- Every deferred item captured in todo.md

## Edge Cases
- User cannot articulate the problem: suggest more discovery before review.
- Plan has no UI scope: skip Section 11 (Design & UX).
- Context is too large: prioritize Step 2 (Premise Challenge) > Error/Rescue Map >
  Test Review > Failure Modes > everything else.
- User wants to change mode mid-review: allow it, but note the mode change and
  re-evaluate any decisions already made under the prior mode.
