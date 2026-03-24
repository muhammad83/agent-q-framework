# Build Plan: gstack Extraction — Stream B (Ship + QA + Docs)
_Created: 2026-03-24_
_Parent plan: ~/.gstack/projects/safqore-agent-q-framework/ceo-plans/2026-03-24-gstack-extraction.md_

## Goal
Extract the ship workflow, code-level QA workflow, and document-release workflow from
gstack into Agent Q. Create corresponding slash commands.

## Decisions
- Ship workflow uses git + gh CLI only — no runtime deps
- QA is code-level only (no browser) — interaction state mapping, edge case matrix,
  error path coverage, input validation audit
- Document-release reads project docs, cross-references git diff, updates stale docs
- Each gets a /q: command in .claude/commands/q/

## Tasks

### Task 1: Ship workflow + command
- **Create** `workflows/ship.md`
  - Source: `.claude/skills/gstack/ship/SKILL.md` (1504 lines → ~200 lines)
  - Distill to: detect base branch, merge base, run tests, review diff,
    bump VERSION (if exists), update CHANGELOG (if exists), commit, push,
    create PR via gh CLI
  - Drop: gstack review dashboard, review readiness checks, VERSION/CHANGELOG
    format enforcement (keep flexible), telemetry, preamble
  - Keep: the shipping ritual steps, PR body format, test-before-ship gate
  - Relationship to /q:finish: ship is the superset. /q:finish handles branch
    cleanup; /q:ship handles the full PR creation pipeline.
- **Create** `.claude/commands/q/ship.md`
  - Slash command that loads workflows/ship.md and executes it
- **Acceptance:** Ship workflow produces a PR end-to-end using git + gh

### Task 2: QA workflow + Document-release workflow + commands
- **Create** `workflows/qa.md`
  - Source: `.claude/skills/gstack/qa-only/SKILL.md` (629 lines → ~150 lines)
  - Distill to: interaction state coverage map (feature × loading/empty/error/success/partial),
    edge case matrix, error path coverage, input validation audit, health score
  - Drop: browser-based testing (that stays in gstack Layer 2), fix loop,
    screenshot evidence, preamble
  - Keep: the QA methodology, severity tiers (Quick/Standard/Exhaustive),
    structured report format
- **Create** `workflows/document-release.md`
  - Source: `.claude/skills/gstack/document-release/SKILL.md` (591 lines → ~100 lines)
  - Distill to: read all project docs, cross-reference git diff since last release,
    update README/ARCHITECTURE/CONTRIBUTING/CLAUDE.md, clean up TODOs, optionally
    bump VERSION
  - Drop: preamble, telemetry
- **Create** `.claude/commands/q/qa.md` and `.claude/commands/q/docs.md`
- **Acceptance:** QA workflow produces structured report. Doc-release updates stale docs.

## Edge Cases
- /q:ship and /q:finish overlap. CLAUDE.md should note: use /q:finish for branch
  cleanup, /q:ship for full PR pipeline. Or consider merging them.
- /q:qa (code-level) coexists with gstack /qa (browser). Different tools, same namespace
  concept. CLAUDE.md should clarify which is which.

## Verification
- Ship workflow can be tested by dry-running on a feature branch
- QA workflow produces a structured report when run on any codebase
- Document-release correctly identifies stale docs via git diff
- All commands appear in /q:status output
