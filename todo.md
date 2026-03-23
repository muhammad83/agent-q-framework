# Agent Q Framework — Project State

## Current Goal
SuperClaude integration — add domain specialist agents and orchestration routing to Agent Q framework.

## Active Tasks
- (none — Stream B complete)

## Recently Completed (SuperClaude Integration — Stream B)
- [x] **Stream B Task 1:** Created 3 specialist agent files (q-security, q-frontend, q-researcher) → `f0011d3`
- [x] **Stream B Task 2:** Added specialist routing to orchestration protocol, updated SKILL.md manifest, updated todo.md

## Previous Goals (Completed)
- [x] Adopt notebooklm-py patterns + add media ingestion to Agent Q (Plans A-D via Spin Jit Su)
- [x] Adopt Agent Skills spec from obsidian-skills → `workflows/build-plan-skills-spec.md`
- [x] Enhance Agent Q with ECC cherry-picked features (orchestration, quality, DX)

## Completed (Spin Jit Su — 4 Parallel Streams)
- [x] **Plan A:** Command Intelligence (autonomy rules + namespace grouping) → `0a2f4e3`
- [x] **Plan B:** Error & Deviation Upgrade (error taxonomy + status tracking) → `ac13f59`
- [x] **Plan C:** Parallel Execution Hardening (config isolation + FIFO cache) → `37277a0`
- [x] **Plan D:** Media Ingestion (`/q:ingest` — yt-dlp + ffmpeg + whisper) → `955c5d9`

## Completed (Earlier)
- [x] Fixed CLAUDE.md context loading (bulk → on-demand) to reduce context waste
- [x] Fixed statusline.cjs math bug (CEILING scaling broke used% calculation)
- [x] Moved statusline.cjs to framework `tools/` directory
- [x] Moved slash commands from `commands/q/` to `.claude/commands/q/`
- [x] Updated `~/.claude/settings.json` to point to framework statusline

## Decisions Made
- Cherry-pick from ECC rather than install whole plugin (context bloat risk)
- On-demand context loading instead of bulk read
- TypeScript + Python as primary language rules (based on project scan)
- Plans A-D are independent → execute via Spin Jit Su (parallel)
- `/q:orchestrate` chains existing subagents (planner → executor → verifier → debugger)
- `/q:spinjitsu` offers both subagent spawning and tmux modes
- notebooklm-py patterns: autonomy rules, error taxonomy, namespace API, config isolation, FIFO cache, poll-based status
- Media ingestion: local-first (yt-dlp + ffmpeg + whisper), no API keys, ~97% coverage
- M2/M5 GPU accelerates whisper via Metal — no slow CPU fallback concern
- Specialists capped at 3: security, frontend, researcher (advise, don't replace pipeline)
- Priority order for specialist ambiguity: security > frontend > researcher
- Specialists loaded as advisors alongside active pipeline agent, not as replacement

## Known Issues
- (none yet)

## Session Log

### Session 1 — 2026-03-20
- What was done: Fixed context loading, fixed statusline, moved commands, scanned projects, planned ECC integration
- What's next: Execute Plans A/B/C in parallel via Spin Jit Su
- Blockers: None

### Session 2 — 2026-03-23
- What was done: Executed SuperClaude Stream B build plan — created 3 specialist agents (q-security, q-frontend, q-researcher), added specialist routing to orchestration protocol, updated SKILL.md manifest and CLAUDE.md context loading
- What's next: Execute remaining SuperClaude integration streams (if any), verify all specialist agents work with orchestration pipeline
- Blockers: None
