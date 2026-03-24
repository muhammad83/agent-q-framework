# CLAUDE.md — [PROJECT NAME]

## Role
You are [ROLE — fill in after interviewing the user].
You follow the Agent Q framework.

## Context Loading (On-Demand)
Load files only when relevant to the current task. Do NOT read everything upfront.

**Always loaded:** This file (CLAUDE.md), soul.md, todo.md, SKILL.md.

**Load on demand:**
- `context/rules.md` — when starting any coding task
- `context/engineering-preferences.md` — when making architecture/style decisions
- `context/planning-protocol.md` — when entering Plan Mode or planning a feature
- `context/frontend.md` — when working on frontend/UI code
- `context/token-efficiency.md` — when context usage is high or agent needs to conserve tokens
- `context/modes.md` — when switching behavioral modes or user requests a specific mode
- `workflows/debug.md` — when debugging issues
- `workflows/code-review.md` — when reviewing code (basic)
- `workflows/review-ceo.md` — when running a CEO/strategy plan review
- `workflows/review-eng.md` — when running an engineering plan review (required shipping gate)
- `workflows/review-design.md` — when running a design plan review
- `workflows/review-pr.md` — when running a pre-landing PR/diff review
- `workflows/pause.md` — when pausing a session
- `workflows/resume.md` — when resuming a paused session
- `workflows/project-setup.md` — when onboarding a new project (first session only)
- `workflows/spin-jit-su-workflow.md` — when using the spin-jit-su workflow
- `shared_context/` — when you need project-specific domain knowledge
- `shared_context/ingested/` — when referencing ingested video/audio content
- `agents/q-planner.md` — when spawning a planner subagent
- `agents/q-executor.md` — when spawning an executor subagent
- `agents/q-verifier.md` — when spawning a verifier subagent
- `agents/q-debugger.md` — when spawning a debugger subagent
- `agents/q-reviewer.md` — when running any review workflow (CEO, eng, design, PR)
- `agents/q-security.md` — when reviewing code for security vulnerabilities
- `agents/q-frontend.md` — when reviewing frontend/UI code quality
- `agents/q-researcher.md` — when conducting structured research or comparisons
- `agents/gemini-cli-extension.md` — when configuring Gemini CLI integration
- `hooks/session-start.sh` — when configuring platform hooks
- `.cursor-plugin/plugin.json` — when setting up for Cursor
- `.codex/setup.md` — when setting up for Codex
- `.opencode/config.json` — when setting up for OpenCode

Track all state in todo.md.

## Tool-Specific Notes (Claude Code)
- `Shift+Tab` — enter/exit Plan Mode
- `/chrome` — open browser for visual verification
- `/clear` — wipe context and start fresh
- `/compact` — summarize and compress current context

## Project Context
[Fill in during project setup: what the project does, who uses it, key features, tech stack.]

## gstack
Use /browse from gstack for all web browsing. Never use mcp__claude-in-chrome__* tools.
Available skills: /office-hours, /plan-ceo-review, /plan-eng-review, /plan-design-review,
/design-consultation, /review, /ship, /land-and-deploy, /canary, /benchmark, /browse,
/qa, /qa-only, /design-review, /setup-browser-cookies, /setup-deploy, /retro,
/investigate, /document-release, /codex, /cso, /autoplan, /careful, /freeze, /guard,
/unfreeze, /gstack-upgrade.
If gstack skills aren't working, run `cd .claude/skills/gstack && ./setup` to rebuild.

## Self-Awareness
You have permission to modify files in /tools/, /workflows/, and /context/ to
improve your own performance.

File map: CLAUDE.md (config), context/ (rules & preferences),
soul.md (personality), todo.md (state), workflows/ (SOPs),
tools/ (scripts), shared_context/ (domain knowledge), agents/ (subagent roles).
