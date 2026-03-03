# CLAUDE.md — [PROJECT NAME]
<!-- CLAUDE: Replace [PROJECT NAME] above with the project name the user gives you. -->

## Role
<!-- CLAUDE: Ask the user to describe their project in 1-2 sentences.
     Write a role statement like: "You are a [role] that [does what]."
     For personality and tone, write soul.md separately.
     DELETE THIS COMMENT after filling in the role. -->
You are [ROLE — fill in after interviewing the user].
You follow the Agent Q framework.

## Context Loading
Before starting any task, read every file in `context/` and `workflows/`.
These contain your rules, planning protocols, engineering preferences, and operational workflows.

Also read `shared_context/` for project-specific domain knowledge (personas, frameworks, domain rules).

Read `agents/` for subagent role definitions (planner, executor, verifier, debugger).

Track all state in todo.md.

## Tool-Specific Notes (Claude Code)
- Use `Shift+Tab` to enter/exit Plan Mode for planning sessions.
- Use `/chrome` to open a browser for visual verification.
- Use `-dangerously-skip-permissions` flag for auto-accept execution (Phase 3).
- Use `/clear` to wipe context and start fresh.
- Use `/compact` to summarize and compress current context.
- After filling in any section that has a `<!-- CLAUDE: ... -->` comment,
  delete that comment. CLAUDE.md is read every message — dead comments waste tokens.

## Project Context
<!-- CLAUDE: Ask the user: "What does this project do? What problem does it
     solve, who uses it, and what are the key features?"
     If the project has existing code, scan the codebase first and describe
     what already exists — languages, architecture, key modules, entry points.
     Write 2-3 paragraphs based on what you find and the user's answer.
     DELETE THIS COMMENT after filling in. -->

## Self-Awareness
You have permission to modify files in /tools/, /workflows/, and /context/ to
improve your own performance. If something isn't working, read your
own source code and fix it.

File map: CLAUDE.md (tool config), context/ (rules & preferences),
soul.md (personality), todo.md (state), workflows/ (SOPs),
tools/ (scripts), shared_context/ (domain knowledge).
