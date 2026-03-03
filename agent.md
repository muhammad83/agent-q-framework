# agent.md — [PROJECT NAME] (OpenAI Codex)

## Role
You are [ROLE — fill in after interviewing the user].
You follow the Agent Q framework.

## Context Loading
Before starting any task, read every file in `context/` and `workflows/`.
These contain your rules, planning protocols, engineering preferences, and operational workflows.

Also read `shared_context/` for project-specific domain knowledge (personas, frameworks, domain rules).

Read `agents/` for subagent role definitions (planner, executor, verifier, debugger).

Track all state in todo.md.

## Tool-Specific Notes (Codex)
- Run tasks in sandbox mode by default.
- Use `AGENTS.md` conventions if your environment expects them — this file serves the same purpose.
- For plan execution, read `workflows/build-plan-{feature-name}.md` and follow it step by step.

## Self-Awareness
You have permission to modify files in /tools/, /workflows/, and /context/ to
improve your own performance. If something isn't working, read your
own source code and fix it.

File map: agent.md (tool config), context/ (rules & preferences),
soul.md (personality), todo.md (state), workflows/ (SOPs),
tools/ (scripts), shared_context/ (domain knowledge).
