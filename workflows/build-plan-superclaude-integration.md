# Build Plan: SuperClaude Integration
_Created: 2026-03-23_
_Discovery Level: 1 (Quick verify)_

## Goal
Enhance Agent Q with 3 capabilities inspired by the SuperClaude Framework, adapted to
Agent Q's tool-agnostic, pass-by-reference, CLI-first architecture:
1. Token-efficiency behavioral mode
2. Domain specialist agents (security, frontend, research)
3. Behavioral modes (research, introspection, efficiency)

All changes are pure markdown config files. Zero new dependencies. Zero runtime changes.

## Decisions
1. Drop MCP integrations — CLI-first per engineering preferences
2. Cap specialist agents at 3 (security, frontend, researcher)
3. Modes are advisory, not enforced — no `/q:mode` command
4. Token-efficiency rules only activate in DEGRADING/POOR context zones (50%+)
5. Priority-based routing for specialist ambiguity (security > frontend > researcher)
6. Specialists advise alongside core 4 pipeline agents, don't replace them
7. Gemini CLI falls back to inline loading for specialists (no subagent spawning)
8. Zero new dependencies — all pure markdown

## Tasks

### Task 1: Token-Efficiency Mode + Behavioral Modes
- **Files:**
  - Create `context/token-efficiency.md`
  - Create `context/modes.md`
  - Modify `CLAUDE.md` (add both files to on-demand loading section)
- **What:**
  - `token-efficiency.md`: Concrete rules for conserving context when usage crosses 50%.
    Covers: batching tool calls, preferring Glob/Grep over Agent for simple searches,
    compact handoff payloads, skipping redundant reads, proactive `/compact` usage,
    terse output style, dropping verbose explanations. Tied to the existing context
    budget table in `planning-protocol.md`.
  - `modes.md`: Three behavioral modes — **Research** (deep investigation, multiple sources,
    structured findings), **Introspection** (meta-cognitive analysis of approach quality,
    self-correction), **Efficiency** (pointer to token-efficiency.md + minimal output +
    maximum parallelism). Each mode defines: when to activate, behavioral overrides,
    tool preferences, output style.
  - `CLAUDE.md`: Add load-on-demand entries for both files.
- **Acceptance:**
  - Both files exist with clear, actionable rules
  - Token-efficiency rules don't contradict engineering-preferences.md
  - Modes don't overlap with existing `/q:brainstorm` behavior
  - CLAUDE.md correctly references both files

### Task 2: Domain Specialist Agents + Orchestration Routing
- **Files:**
  - Create `agents/q-security.md`
  - Create `agents/q-frontend.md`
  - Create `agents/q-researcher.md`
  - Modify `workflows/orchestration-protocol.md` (add specialist routing table)
  - Modify `SKILL.md` (add new capabilities and agents)
  - Modify `todo.md` (update project state)
- **What:**
  - Each specialist follows the exact pattern of `agents/q-planner.md`: identity, triggers
    (keywords + file patterns), core responsibilities, what they do/don't do, context
    loading instructions, and handoff format.
  - `q-security.md`: Triggers on keywords like "vulnerability", "XSS", "auth", "OWASP",
    "injection", "CVE". Reviews code for OWASP Top 10, dependency vulnerabilities,
    auth/authz issues. Does NOT make architectural decisions or replace q-verifier.
  - `q-frontend.md`: Triggers on keywords like "UI", "CSS", "component", "layout",
    "responsive", "accessibility". Reviews for a11y, performance, component patterns.
    Does NOT make design decisions or choose frameworks.
  - `q-researcher.md`: Triggers on keywords like "research", "compare", "evaluate",
    "alternatives", "best practice". Performs structured investigation with multiple
    sources, produces findings documents. Does NOT make decisions — presents options.
  - `orchestration-protocol.md`: Add a "Specialist Routing" section after the Agent Chain
    section. Defines: routing table (keyword/file triggers → specialist), priority order
    (security > frontend > researcher), invocation rules (orchestrator loads specialist
    as advisor alongside the active pipeline agent, not as replacement).
  - `SKILL.md`: Add specialists to agents list, add "domain-specialists" and
    "behavioral-modes" and "token-efficiency" to provides list.
- **Acceptance:**
  - All 3 specialist files exist with proper frontmatter and follow q-planner.md pattern
  - Orchestration protocol has routing table with clear priority rules
  - SKILL.md manifest is accurate
  - `/q:status` output reflects the new agents (via SKILL.md)
  - todo.md updated with completed goal

## Edge Cases
1. **Routing ambiguity** — Security wins over frontend when both match. Orchestrator picks
   one specialist, not multiple. If no specialist matches, no specialist is loaded (default).
2. **Token-efficiency vs thoroughness** — Efficiency rules only activate at 50%+ context.
   In PEAK/GOOD zones, engineering preferences (thoroughness) take priority.
3. **Gemini CLI** — Falls back to inline loading. Specialist file is read directly by the
   orchestrator instead of spawning a subagent.
4. **Specialist bloat** — Capped at 3. Future specialists require a demonstrated need from
   a real project before being added.

## Dependencies
None. Zero new libraries, services, or environment variables.

## Rollback
`git revert` the commit(s). All changes are additive:
- New files: delete them. Nothing references them unless explicitly loaded on demand.
- Modified files: revert to previous commit. Additions are isolated sections.

## Verification
1. Run `./tools/verify.sh` on each new file
2. Verify CLAUDE.md on-demand loading entries point to correct paths
3. Manually test orchestration routing with a security-related prompt
4. Confirm token-efficiency rules don't contradict engineering-preferences.md
5. Confirm modes.md doesn't duplicate `/q:brainstorm` behavior
6. Verify SKILL.md manifest accuracy
7. Check `/q:status` reflects new capabilities
