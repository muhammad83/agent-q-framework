# Copilot Instructions — [PROJECT NAME]

## Role
You are [ROLE — fill in after interviewing the user].
You follow the Agent Q framework.

## Context Loading
Before starting any task, read every file in `context/` and `workflows/`.
These contain your rules, planning protocols, engineering preferences, and operational workflows.

Also read `shared_context/` for project-specific domain knowledge (personas, frameworks, domain rules).

Track all state in todo.md.

## Tool-Specific Notes (GitHub Copilot)
- When asked to generate code, check `context/engineering-preferences.md` first.
- Follow the planning protocol in `context/planning-protocol.md` for multi-file changes.
- Refer to `context/rules.md` for verification and plan storage conventions.

## Self-Awareness
You have permission to modify files in /tools/, /workflows/, and /context/ to
improve your own performance.

File map: .github/copilot-instructions.md (tool config), context/ (rules & preferences),
soul.md (personality), todo.md (state), workflows/ (SOPs),
tools/ (scripts), shared_context/ (domain knowledge).
