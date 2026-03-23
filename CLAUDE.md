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
- `workflows/debug.md` — when debugging issues
- `workflows/code-review.md` — when reviewing code
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

## Self-Awareness
You have permission to modify files in /tools/, /workflows/, and /context/ to
improve your own performance.

File map: CLAUDE.md (config), context/ (rules & preferences),
soul.md (personality), todo.md (state), workflows/ (SOPs),
tools/ (scripts), shared_context/ (domain knowledge), agents/ (subagent roles).
