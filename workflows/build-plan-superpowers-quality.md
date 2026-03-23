---
plan: superpowers-quality
status: pending
stream: A
parallel: true
discovery: 1
---

# Build Plan — Superpowers Quality Integration

Cherry-pick TDD enforcement, two-stage review, and document review loops from Superpowers into Agent Q.

## Decisions

- TDD workflow is a new workflow file + new `/q:tdd` command
- TDD only activates for application code tasks, not config/docs/workflow changes
- Two-stage review enhances existing q-verifier.md (spec compliance + code quality as separate passes)
- `/q:verify` gets two-stage by default + `--quick` flag for trivial changes
- Document review loop adds subagent reviewer step between planning and execution
- Review loop capped at 3 iterations before surfacing to human
- `/q:plan` and `/q:orchestrate` both wire in document review

## Task 1 — TDD Workflow + Command

**Create:** `workflows/tdd.md`
- Red-green-refactor cycle with mandatory "watch it fail" step
- Trigger condition: only when task produces application code (not config, docs, workflows)
- Anti-pattern reference (testing after code, skipping "too simple" cases, mocking everything)
- Integration point: `/q:execute` can opt into TDD mode

**Create:** `.claude/commands/q/tdd.md`
- Autonomy: confirm
- Namespace: execution
- Loads `workflows/tdd.md` and `context/rules.md`
- Sets up test file first, refuses production code until test fails
- Enforces red-green-refactor cycle per unit of work

**Modify:** `.claude/commands/q/execute.md`
- Add optional TDD mode flag — when set, executor follows `workflows/tdd.md` discipline during implementation

**Verify:** Run `/q:tdd` on a sample task. Confirm it creates test first, refuses prod code until test fails, follows red-green-refactor.

## Task 2 — Two-Stage Review

**Modify:** `agents/q-verifier.md`
- Split verification into two distinct passes:
  - **Pass 1 — Spec Compliance:** Does the implementation match what was planned? Check every requirement in the build plan against the code. Verdict: COMPLIANT / DEVIATION FOUND
  - **Pass 2 — Code Quality:** Is the implementation well-built? Architecture, DRY, edge cases, security, performance. Verdict: CLEAN / ISSUES FOUND
- Each pass produces its own section in the verification report
- Quick mode: single combined pass for trivial changes (triggered by `--quick` flag)

**Modify:** `.claude/commands/q/verify.md`
- Update to reference two-stage review in q-verifier.md
- Add `--quick` flag support for single-pass mode on trivial changes

**Verify:** Run `/q:verify` on completed work. Confirm output has two distinct sections (spec compliance, code quality). Test `--quick` flag produces single combined section.

## Task 3 — Document Review Loop

**Modify:** `workflows/orchestration-protocol.md`
- Add document review step between planning phase and execution phase
- After plan is generated, dispatch a subagent reviewer to evaluate the plan for:
  - Completeness (are all requirements addressed?)
  - Feasibility (can each task be done in the stated scope?)
  - Risks (any gaps, ambiguities, or contradictions?)
- Cap at 3 review iterations — after that, surface remaining concerns to human
- Reviewer verdict: APPROVED / REVISE (with specific feedback)

**Modify:** `.claude/commands/q/plan.md`
- After plan generation, trigger document review loop before finalizing
- Show user the reviewer's verdict and any revisions made

**Modify:** `.claude/commands/q/orchestrate.md`
- Wire document review into the planner→executor handoff

**Verify:** Run `/q:plan` on a feature. Confirm subagent reviewer is dispatched after plan generation. Confirm 3-iteration cap.

## Edge Cases

- TDD gating: workflow checks task type before activating — config/docs/workflow tasks skip TDD
- Two-stage quick mode: `--quick` flag combines passes for 1-2 file changes
- Review loop cap: hard limit of 3 iterations prevents infinite revision cycles
- Backward compatibility: existing `/q:verify` behavior preserved as default (two-stage is additive, not breaking)

## Rollback

- Task 1: delete `workflows/tdd.md` + `.claude/commands/q/tdd.md`, revert execute.md change
- Task 2: `git revert` the q-verifier.md and verify.md commits
- Task 3: `git revert` the orchestration-protocol.md, plan.md, and orchestrate.md commits
- All tasks independent — can revert any without affecting others
