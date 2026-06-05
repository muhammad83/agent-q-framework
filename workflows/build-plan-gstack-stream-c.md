# Build Plan: gstack Extraction — Stream C (Safety + Retro + Multi-AI)
_Created: 2026-03-24_
_Parent plan: ~/.gstack/projects/agent-q-framework/ceo-plans/2026-03-24-gstack-extraction.md_

## Goal
Extract safety modes, retrospective workflow, and multi-AI verification protocol
from gstack into Agent Q. These are the lightweight extractions (S effort each).

## Decisions
- Safety modes are behavioral context files, not hook-based enforcement
- Advisory over enforced, portable over strict (same trade-off as all Agent Q modes)
- Retro uses git log analysis only — no external deps
- Multi-AI verification adapted from gstack /codex — platform-agnostic cross-model check

## Tasks

### Task 1: Safety modes (careful + freeze + unfreeze + guard)
- **Create** `context/safety-careful.md`
  - Source: `.claude/skills/gstack/careful/SKILL.md` (60 lines → ~60 lines)
  - Dangerous command patterns: rm -rf, DROP TABLE, force-push, git reset --hard,
    kubectl delete, docker system prune, chmod -R 777
  - Rule: before executing any of these, state what will happen, show the blast
    radius, and ask for confirmation. If the user hasn't explicitly requested
    the destructive action, refuse.
  - Platform-agnostic: works as behavioral rule on any tool
- **Create** `context/safety-freeze.md`
  - Source: `.claude/skills/gstack/freeze/SKILL.md` (83 lines → ~60 lines)
  - Rule: only edit files within the specified directory. If a tool call would
    modify a file outside this directory, refuse and explain why.
  - Activation: user adds `freeze_scope: src/` to CLAUDE.md or prompts
    "freeze everything outside src/"
- **Create** `context/safety-unfreeze.md`
  - Source: `.claude/skills/gstack/unfreeze/SKILL.md` (41 lines → ~30 lines)
  - Rule: clear the freeze boundary, allow edits to all directories
- **Create** `workflows/guard.md`
  - Source: `.claude/skills/gstack/guard/SKILL.md` (83 lines → ~50 lines)
  - Combined mode: load both safety-careful.md and safety-freeze.md
- **Modify** `CLAUDE.md` — add safety files to on-demand loading section
- **Acceptance:** Safety rules are clear, actionable, platform-agnostic

### Task 2: Retro + Multi-AI verification + commands + manifest
- **Create** `workflows/retro.md`
  - Source: `.claude/skills/gstack/retro/SKILL.md` (1050 lines → ~150 lines)
  - Distill to: git log analysis (commits by author, files changed, churn),
    work pattern analysis (commit frequency, time of day, file hotspots),
    code quality signals (test ratio, TODO/FIXME count, large commits),
    team breakdown with per-person highlights, retrospective questions
  - Drop: persistent history tracking, trend tracking, preamble, telemetry
  - Keep: the structured analysis methodology, praise + growth areas format
- **Create** `workflows/multi-ai-verify.md`
  - Source: adapted from `.claude/skills/gstack/codex/SKILL.md` (673 lines → ~100 lines)
  - Protocol: spawn subagent on different model (or platform), pass the code/plan,
    structured comparison of findings, flag cross-model tension points
  - Platform-agnostic: on Claude → spawn Sonnet to check Opus (or vice versa),
    on Cursor → use different model, on Codex → use Claude as second opinion
  - Not tied to OpenAI Codex CLI — generalized to any cross-model verification
- **Create** `.claude/commands/q/retro.md` and `.claude/commands/q/guard.md`
- **Modify** `SKILL.md` — add all new capabilities: review-gates, qa, ship, safety,
  retro, multi-ai-verify, document-release. Add q-reviewer agent.
- **Modify** `CLAUDE.md` — add all new workflows to on-demand loading
- **Modify** `todo.md` — update with gstack extraction goal and completion
- **Acceptance:** All files exist, SKILL.md accurate, CLAUDE.md references correct

## Edge Cases
- Multi-AI verification assumes subagent spawning. On platforms without it (Gemini CLI),
  fall back to "run the verification manually in a separate session."
- Retro on a solo developer project: skip team breakdown, focus on personal patterns.
- Guard mode stacking: if both careful and freeze are loaded, both apply simultaneously.

## Verification
- Safety-careful: test by prompting agent to run `rm -rf /` — should refuse
- Safety-freeze: test by prompting agent to edit outside frozen directory — should refuse
- Retro: test by running on this repo — should produce structured analysis
- Multi-AI verify: test by spawning a subagent reviewer on a small code change
- SKILL.md lists all new capabilities and agents
- CLAUDE.md on-demand loading has all new file references
