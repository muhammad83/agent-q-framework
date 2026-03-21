# Build Plan A: Command Intelligence

## Goal
Add autonomy rules and namespace grouping to all `/q:` commands so orchestration can route and auto-approve intelligently.

## Discovery Level
Level 0 — Internal work, existing patterns.

## Tasks

### Task 1: Add Autonomy Rules to All Commands
Add `autonomy:` frontmatter to every `.claude/commands/q/*.md` file.

**Autonomy levels:**
- `auto` — Safe to run without confirmation (read-only, status, progress)
- `confirm` — Ask user before proceeding (plan, execute, orchestrate, spinjitsu)
- `block` — Never auto-run, always requires explicit user invocation (debug, pause)

**Assignments:**

| Command | Autonomy | Rationale |
|---------|----------|-----------|
| plan | confirm | Creates artifacts, needs user input |
| execute | confirm | Writes code, modifies files |
| verify | auto | Read-only analysis |
| review | auto | Read-only analysis |
| debug | confirm | May modify code to fix issues |
| quick | confirm | Writes code |
| progress | auto | Read-only status check |
| pause | auto | Saves state, non-destructive |
| resume | auto | Reads state, non-destructive |
| orchestrate | confirm | Spawns multiple agents, writes code |
| spinjitsu | confirm | Spawns parallel agents |
| status | auto | Read-only listing |

### Task 2: Add Namespace Grouping
Add `namespace:` frontmatter to each command for logical grouping.

**Namespaces:**

| Namespace | Commands |
|-----------|----------|
| planning | plan |
| execution | execute, quick, orchestrate, spinjitsu |
| quality | verify, review, debug |
| dx | progress, pause, resume, status |

Update `SKILL.md` command table to show namespaces.

## Files

| Action | File |
|--------|------|
| Modify | `.claude/commands/q/plan.md` |
| Modify | `.claude/commands/q/execute.md` |
| Modify | `.claude/commands/q/verify.md` |
| Modify | `.claude/commands/q/review.md` |
| Modify | `.claude/commands/q/debug.md` |
| Modify | `.claude/commands/q/quick.md` |
| Modify | `.claude/commands/q/progress.md` |
| Modify | `.claude/commands/q/pause.md` |
| Modify | `.claude/commands/q/resume.md` |
| Modify | `.claude/commands/q/orchestrate.md` |
| Modify | `.claude/commands/q/spinjitsu.md` |
| Modify | `.claude/commands/q/status.md` |
| Modify | `SKILL.md` |

## Edge Cases
- Commands with no existing frontmatter — add full frontmatter block
- Commands with existing frontmatter — append new fields, don't break existing ones

## Verification
- All 12 command files have `autonomy:` and `namespace:` in frontmatter
- SKILL.md command table shows autonomy and namespace columns
- No existing frontmatter fields broken

## Rollback
Remove `autonomy:` and `namespace:` lines from frontmatter. Revert SKILL.md table.
