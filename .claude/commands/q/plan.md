---
name: q:plan
description: Start a structured planning session with reverse elicitation
triggers: [plan, interview, design, scope, feature planning]
argument-hint: "[2-3 sentence project/feature description]"
allowed-tools: [Read, Glob, Grep, WebSearch, WebFetch, AskUserQuestion]
autonomy: confirm
namespace: planning
---

## Objective
Interview the user about a feature or project using the Reverse Elicitation method,
then produce a detailed build plan saved to `workflows/build-plan-{feature-name}.md`.

## Execution Context
- Read `context/planning-protocol.md` for the 8-question interview framework
- Read `context/rules.md` for plan storage conventions
- Read `context/engineering-preferences.md` for coding standards
- Check `todo.md` for current project state

## Process

1. **Load context.** Read all files in `context/` and `workflows/`. Read `todo.md`.

2. **Interview.** Ask the user each question from the planning protocol:
   - Goal, Scope, Approach, Edge cases, Trade-offs, Dependencies, Testing, Rollback
   - For each question: give your recommended answer and rationale, then ask if they agree
   - If the user says "you decide" or "not sure", accept your recommendation and move on

3. **Assess discovery level.** Based on uncertainty, set the discovery level (0-3)
   from `context/planning-protocol.md` → Discovery Levels. Default to Level 1.

4. **Summarize decisions.** Before writing the plan, present all decisions in a
   numbered list. Get user confirmation.

5. **Write plan.** Save to `workflows/build-plan-{feature-name}.md` with:
   - Every decision made
   - Task breakdown (2-3 tasks max per context budget rules)
   - File list (create/modify/delete)
   - Edge cases and rollback strategy
   - Verification criteria

6. **Update todo.md** with the new plan reference.

## Success Criteria
- All 8 planning questions answered or explicitly deferred
- Plan saved to `workflows/build-plan-{feature-name}.md`
- Plan has 2-3 tasks max (per context budget awareness rules)
- Discovery level assessed and noted
- `todo.md` updated with plan reference
