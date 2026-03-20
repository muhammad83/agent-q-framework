# Agent Q Framework — Project State

## Current Goal
- [ ] Enhance Agent Q with ECC cherry-picked features (orchestration, quality, DX)

## Active Tasks (Spin Jit Su — Parallel Execution)
- [ ] **Plan A:** Multi-agent orchestration (`/q:orchestrate` + `/q:spinjitsu`) → `workflows/build-plan-orchestration.md`
- [ ] **Plan B:** Token optimization + language rules + security scanning → `workflows/build-plan-quality.md`
- [ ] **Plan C:** Hook profiles + session persistence → `workflows/build-plan-dx.md`

## Completed
- [x] Fixed CLAUDE.md context loading (bulk → on-demand) to reduce context waste
- [x] Fixed statusline.cjs math bug (CEILING scaling broke used% calculation)
- [x] Moved statusline.cjs to framework `tools/` directory
- [x] Moved slash commands from `commands/q/` to `.claude/commands/q/`
- [x] Updated `~/.claude/settings.json` to point to framework statusline

## Decisions Made
- Cherry-pick from ECC rather than install whole plugin (context bloat risk)
- On-demand context loading instead of bulk read
- TypeScript + Python as primary language rules (based on project scan)
- Plans A/B/C are independent → execute via Spin Jit Su (parallel)
- `/q:orchestrate` chains existing subagents (planner → executor → verifier → debugger)
- `/q:spinjitsu` offers both subagent spawning and tmux modes

## Known Issues
- (none yet)

## Session Log

### Session 1 — 2026-03-20
- What was done: Fixed context loading, fixed statusline, moved commands, scanned projects, planned ECC integration
- What's next: Execute Plans A/B/C in parallel via Spin Jit Su
- Blockers: None
