# Build Plan: gstack Extraction — Stream A (Review Gates)
_Created: 2026-03-24_
_Parent plan: ~/.gstack/projects/safqore-agent-q-framework/ceo-plans/2026-03-24-gstack-extraction.md_

## Goal
Extract the 4 review gate workflows from gstack into Agent Q's pass-by-reference
architecture. Create the q-reviewer agent role. Wire into CLAUDE.md and SKILL.md.

## Decisions
- Distill 800-1400 line gstack mega-prompts into 150-300 line focused workflows
- Remove Claude Code-specific patterns (AskUserQuestion → "ask the user", bash preamble → drop)
- Preserve the methodology (questions to ask, checks to run, edge cases to look for)
- q-reviewer agent is shared across all 4 review workflows
- Follow existing Agent Q workflow format (_TEMPLATE.md)

## Extraction Methodology
For each gstack SKILL.md:
1. Read the original skill file from `.claude/skills/gstack/{skill}/SKILL.md`
2. Identify the core methodology sections (the questions, checks, criteria)
3. Strip: preamble, telemetry, AskUserQuestion format, bash scripts, gstack-specific infra
4. Adapt: replace Claude Code patterns with platform-agnostic equivalents
5. Write in Agent Q workflow format with YAML frontmatter

## Tasks

### Task 1: Create q-reviewer agent + review-ceo workflow
- **Create** `agents/q-reviewer.md`
  - Shared reviewer agent identity (used by all 4 review workflows)
  - Defines: review posture, output format (structured report with severity),
    severity levels (CRITICAL GAP / WARNING / OK), handoff format
  - Follows q-planner.md pattern: frontmatter, identity, responsibilities,
    what they do/don't do, context loading, handoff
- **Create** `workflows/review-ceo.md`
  - Source: `.claude/skills/gstack/plan-ceo-review/SKILL.md` (1394 lines → ~200 lines)
  - Distill to: premise challenge (3 questions), existing code leverage,
    dream state mapping, implementation alternatives (mandatory), mode selection
    (expansion/selective/hold/reduction), scope decision ceremony
  - Drop: preamble, telemetry, upgrade checks, spec review loop, design doc check,
    handoff notes, lake intro, contributor mode, review dashboard
  - Keep: the 10x check, platonic ideal, temporal interrogation, mode comparison table
- **Acceptance:** Both files exist, follow Agent Q patterns, methodology is preserved

### Task 2: Create review-eng + review-design + review-pr workflows
- **Create** `workflows/review-eng.md`
  - Source: `.claude/skills/gstack/plan-eng-review/SKILL.md` (970 lines → ~250 lines)
  - Distill to: architecture review, error/rescue map, security/threat model,
    test coverage diagram, performance review, observability, deployment review
  - This is the required shipping gate — note that in the workflow
- **Create** `workflows/review-design.md`
  - Source: `.claude/skills/gstack/plan-design-review/SKILL.md` (850 lines → ~150 lines)
  - Distill to: information architecture, interaction state coverage map,
    a11y basics, responsive intention, design system alignment
- **Create** `workflows/review-pr.md`
  - Source: `.claude/skills/gstack/review/SKILL.md` (888 lines → ~150 lines)
  - Distill to: diff analysis, SQL safety, security boundary violations,
    conditional side effects, test coverage for changed code
- **Acceptance:** All 3 files exist, follow workflow format, methodology preserved

## Edge Cases
- review-eng is the most complex (11 sections in gstack). Focus on the highest-value
  sections: architecture, error map, test coverage, security. Defer observability and
  deployment to "see also" references.
- review-pr overlaps with Agent Q's existing /q:review. The new workflow should be a
  superset — agents load review-pr.md instead of the simpler existing review.

## Verification
- All 5 files pass ./tools/verify.sh (after updating verify.sh for workflow checks)
- Each review workflow has: trigger, context needed, steps, output, success criteria
- q-reviewer.md has proper frontmatter and follows agent pattern
- No Claude Code-specific patterns remain (no AskUserQuestion, no bash preamble)
