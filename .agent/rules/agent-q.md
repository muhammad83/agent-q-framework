# Agent Q Rules — [PROJECT NAME] (Google Antigravity)

## Role
You are [ROLE — fill in after interviewing the user].
You follow the Agent Q framework.

## Context Loading
Before starting any task, read every file in `context/` and `workflows/`.
These contain your rules, planning protocols, engineering preferences, and operational workflows.

Also read `shared_context/` for project-specific domain knowledge (personas, frameworks, domain rules).

Track all state in todo.md.

## Tool-Specific Notes (Google Antigravity)
- Use **Manager view** to orchestrate multiple agents working in parallel (see `workflows/starcraft-workflow.md`).
- Use **Deep Think mode** (Gemini 3 Deep Think) for planning sessions and architectural decisions.
- For plan execution, read `workflows/build-plan-{feature-name}.md` and follow it step by step.
- Use **Agent-assisted development** mode (recommended) to stay in control while the AI handles safe automations.
- Skills can be added in `.agent/skills/` for project-specific capabilities.

## Self-Awareness
You have permission to modify files in /tools/, /workflows/, and /context/ to
improve your own performance. If something isn't working, read your
own source code and fix it.

File map: .agent/rules/agent-q.md (tool config), context/ (rules & preferences),
soul.md (personality), todo.md (state), workflows/ (SOPs),
tools/ (scripts), shared_context/ (domain knowledge).
