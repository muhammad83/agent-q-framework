# Agent Q Framework — Project State

## Current Goal
Full gstack extraction — separate behavioral prompts from runtime tools, extract all P1
skills into Agent Q's pass-by-reference architecture. CEO plan approved (SCOPE EXPANSION,
7/7 proposals accepted).

## Active Tasks
- [ ] **Token Economy Tooling** (no-cache Bedrock Sonnet, $40/day) → `workflows/build-plan-token-economy.md`. Planned + self-review APPROVED 2026-06-04. 3 independent tasks:
  - [x] **Task 1:** `tools/budget-guard.sh` workday pacer + pace-aware statusline segment + `context/budget-discipline.md` + `.env.example` vars → `410392c` (plus `fe26b0d` verify.sh ugrep fix). Verified: all modes run, statusline renders budget line, doc passes verify.sh.
  - [ ] **Task 2:** `/q:estimate` + `tools/estimate-plan.py` pre-flight plan cost forecaster.
  - [ ] **Task 3:** `/q:opus` model-tiered run + `context/model-tiers.md`.
  - Run each remaining task as its own `/q:execute` (or spinjitsu) with `/clear` between.
- [ ] **Stream A:** Review Gates (CEO/Eng/Design/PR + q-reviewer agent) → `workflows/build-plan-gstack-stream-a.md`
- [x] **Stream B:** Ship + QA + Document-Release workflows → `workflows/build-plan-gstack-stream-b.md`
  - Ship workflow (`workflows/ship.md`, 240 lines) + `/q:ship` command → `baede98`
  - QA workflow (`workflows/qa.md`, 215 lines) + `/q:qa` command → `7633107`
  - Document-release workflow (`workflows/document-release.md`, 174 lines) + `/q:docs` command → `7633107`
- [ ] **Stream C:** Safety + Retro + Multi-AI verification → `workflows/build-plan-gstack-stream-c.md`

## External Plans (Other Repos)
- [x] **Penfold preview cleanup hardening** (target repo: `infrastructure-as-code` on `penfold` branch) → `workflows/build-plan-penfold-preview-cleanup.md`. Document review APPROVED 2026-05-02 (iteration 3/3). Executed 2026-05-02. Three commits on penfold branch: `98ca23f` (vault scope refactor), `3b5769a` (script + playbook + inventory + vault), `fcc78bc` (URL-embedded git auth — required because git 2.43 ignores `http.extraHeader`). End-to-end verification on live server passed: audit OK, dry-run correct, network-failure sim preserves all containers, real run deletes only deleted-branch container. Cron re-enabled. Soak window: confirm previews persist through next four cron firings (06/12/18/00 UTC) over 24h.
- [x] **Superman Protocol — v3 Sprint 1 SHIPPED 2026-05-20** (target repo: `~/Documents/Projects/superman-protocol/`). Tag `v0.2-vertical-push`. Vertical slice across all 3 pillars (Session Driver + Coach + Body). Plan: `superman-protocol/workflows/build-plan-v3-companion.md`. Commits `f275c48` / `12a67cf` / `5d19745`. 59 tests, 647 KB JS / 196 KB gzip.
- [ ] **Superman Protocol — v3 Sprint 2 PLANNED 2026-05-21** → `superman-protocol/workflows/build-plan-v3-companion-sprint2.md`. Self-review APPROVED. Reframes Sprint 2 honestly — the v3 plan's "horizontal port to Days 2–5" turned out to be mostly free because the state machine generalizes; Sprint 2 is verification + the quality gaps Day-1 use exposes. 3 atomic tasks (~3.5 days): (A) end-to-end day-walk tests + edit-history + quick-rest trigger fix, (B) Coach bundle split (~440 KB initial vs 647) + streaming responses, (C) real Settings screen + home consolidation. Tag `v0.3-week-1` on completion. Sprint 3 (Capacitor + HealthKit + iCloud) deferred.

## Recently Completed (SuperClaude Integration — 2 Parallel Streams)

## Recently Completed (SuperClaude Integration — 2 Parallel Streams)
- [x] **Stream A Task 1:** Token-efficiency rules (`context/token-efficiency.md`) → `d7259bb`
- [x] **Stream A Task 2:** Behavioral modes (`context/modes.md`) → `58f96b1`
- [x] **Stream A Task 3:** CLAUDE.md on-demand loading updated → `7123a3f`

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

## Previous Goals (Completed)
- [x] Adopt notebooklm-py patterns + media ingestion via Spin Jit Su (Plans A-D)

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
- Superpowers: integrate all 7 capabilities (not cherry-pick 3) — same pattern as GSD/ECC/notebooklm-py integrations
- Superpowers streams: A (quality), B (DX), C (platform) — independent, parallel via Spin Jit Su
- TDD only for application code, not config/docs/workflows
- Two-stage review default + --quick flag for trivial changes
- Document review loop capped at 3 iterations
- Visual brainstorm: zero-dependency Node.js, 30min idle timeout, parent PID monitoring
- Multi-platform: single source of truth in SKILL.md, platform configs derive from it
- SuperClaude: drop MCP integrations, keep CLI-first philosophy
- Specialists capped at 3: security, frontend, researcher (advise, don't replace pipeline)
- Priority order for specialist ambiguity: security > frontend > researcher
- Specialists loaded as advisors alongside active pipeline agent, not as replacement
- Token-efficiency rules only activate in DEGRADING/POOR context zones (50%+)
- Behavioral modes are advisory, not enforced — no /q:mode command

## Known Issues
- (none yet)

## Session Log

### Session 3 — 2026-03-23
- What was done: Researched SuperClaude Framework, planned integration of best ideas (token-efficiency, modes, specialists), executed 2 parallel streams via Spin Jit Su subagent spawning, resolved merge conflicts, merged both streams into main
- What's next: Verify all new files work with orchestration pipeline
- Blockers: None

### Session 2 — 2026-03-23
- What was done: Researched Superpowers framework, planned integration of all 7 capabilities, wrote 3 parallel build plans, executed all 3 streams via Spin Jit Su, merged into main
- What's next: Verify integrated features
- Blockers: None

### Session 1 — 2026-03-20
- What was done: Fixed context loading, fixed statusline, moved commands, scanned projects, planned ECC integration
- What's next: Execute Plans A/B/C in parallel via Spin Jit Su
- Blockers: None
