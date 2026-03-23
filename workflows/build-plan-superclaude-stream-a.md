# Build Plan: SuperClaude Stream A — Token-Efficiency + Behavioral Modes
_Created: 2026-03-23_
_Parent plan: workflows/build-plan-superclaude-integration.md_

## Goal
Create token-efficiency behavioral rules and behavioral modes as context files,
and wire them into CLAUDE.md on-demand loading.

## Decisions
- Token-efficiency rules only activate in DEGRADING/POOR context zones (50%+)
- Modes are advisory, not enforced — no `/q:mode` command
- Three modes: Research, Introspection, Efficiency
- Don't duplicate existing `/q:brainstorm` behavior
- Don't contradict engineering-preferences.md

## Tasks

### Task 1: Create context/token-efficiency.md
- **Create** `context/token-efficiency.md`
- **Content:** Concrete rules for conserving context when usage crosses 50%.
  Covers: batching tool calls, preferring Glob/Grep over Agent for simple searches,
  compact handoff payloads, skipping redundant reads, proactive `/compact` usage,
  terse output style, dropping verbose explanations. Reference the context budget
  table in `planning-protocol.md`. Include a "When to activate" section that ties
  to the DEGRADING (50-70%) and POOR (70%+) zones. Include a "When NOT to activate"
  section clarifying that PEAK/GOOD zones follow normal engineering preferences
  (thoroughness over speed).
- **Acceptance:** File exists, rules are actionable, no contradiction with engineering-preferences.md

### Task 2: Create context/modes.md
- **Create** `context/modes.md`
- **Content:** Three behavioral modes:
  1. **Research mode** — Deep investigation. Multiple sources. Structured findings
     document. Tool preferences: WebSearch, Grep broadly, read external docs.
     Output style: structured report with sources, options, and trade-offs.
     When to activate: user says "research this", "compare options", "evaluate
     alternatives", or task involves unfamiliar technology (Discovery Level 2-3).
  2. **Introspection mode** — Meta-cognitive analysis. Agent evaluates its own
     approach quality, checks for drift from the plan, identifies assumptions
     it's making. Output style: self-assessment with corrections. When to activate:
     after 3+ tasks without user feedback, when hitting repeated errors, or when
     user says "check yourself" / "are you on track?"
  3. **Efficiency mode** — Maximum throughput, minimum tokens. Points to
     token-efficiency.md for rules. Additional: prefer parallel tool calls,
     skip explanations, commit frequently, use `/compact` aggressively.
     When to activate: context usage > 50%, or user says "be efficient" /
     "speed mode".
  Each mode section includes: When to Activate, Behavioral Overrides, Tool
  Preferences, Output Style.
- **Acceptance:** File exists, 3 modes defined, no overlap with `/q:brainstorm`

### Task 3: Update CLAUDE.md on-demand loading
- **Modify** `CLAUDE.md`
- **What:** Add two entries to the "Load on demand" section:
  - `context/token-efficiency.md` — when context usage is high or agent needs to conserve tokens
  - `context/modes.md` — when switching behavioral modes or user requests a specific mode
- **Acceptance:** CLAUDE.md references both files in the on-demand loading section

## Verification
- Both context files exist with clear, actionable content
- CLAUDE.md on-demand section correctly references both files
- Token-efficiency rules reference the context budget table from planning-protocol.md
- Modes don't duplicate `/q:brainstorm` behavior
- No contradictions with engineering-preferences.md
