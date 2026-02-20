# CLAUDE.md — [PROJECT NAME]
<!-- CLAUDE: Replace [PROJECT NAME] above with the project name the user gives you. -->

## Role
<!-- CLAUDE: Ask the user to describe their project in 1-2 sentences.
     Write a role statement like: "You are a [role] that [does what]."
     For personality and tone, write soul.md separately.
     DELETE THIS COMMENT after filling in the role. -->
You are [ROLE — fill in after interviewing the user].
You follow the Agent Q framework:
- Read Workflows in /workflows for your instructions.
- Execute Tools in /tools for actions.
- Track all state in todo.md.

## Rules
1. Before starting any task, read todo.md for current project state.
2. After completing any task, update todo.md with what was done.
3. You (Claude) are expected to edit all files in this project, including CLAUDE.md.
   If the user corrects a behavior during a session, update CLAUDE.md yourself to prevent recurrence.
4. Keep all workflow instructions in /workflows as .md files.
5. Keep all executable scripts in /tools.
6. Never store secrets in code. Use .env files.
7. When unsure about a decision, ask — don't guess.
8. Follow the Planning Protocol below before writing code for multi-file changes or new features.
9. 2-Strike Rule: If the user corrects you twice on the same mistake,
   stop and ask for clarification rather than guessing again.
10. After filling in any section that has a `<!-- CLAUDE: ... -->` comment,
    delete that comment. CLAUDE.md is read every message — dead comments waste tokens.

## Planning Protocol
Before any change that touches more than 2 files or adds a new feature, interview me with the questions below. Provide your recommended answer for each question. Do not write code until we have agreed on the answers.

1. **Goal** — What exactly are we building and why?
2. **Scope** — Which files and modules will be created or modified?
3. **Approach** — What is the implementation strategy? Are there alternatives?
4. **Edge cases** — What could go wrong or behave unexpectedly?
5. **Trade-offs** — What are we gaining and what are we giving up?
6. **Dependencies** — Do we need new libraries, services, or environment variables?
7. **Testing** — How will we verify this works?
8. **Rollback** — If this breaks something, how do we undo it?

If I say "you decide" or "not sure" on any question, go with your recommendation and move on.

For single-file fixes, bug patches, or trivial edits, skip the interview and just do it.

After the interview, save the agreed plan to the location described in Plan Storage below.

## Plan Storage
Save implementation plans to `workflows/build-plan-{feature-name}.md`. Never save plans to `~/.claude/plans/`. Plans must live in the project repo so they are tracked in git and reviewable.

## Verification
After completing any build task:
1. Run any existing tests (`pytest`, `ruff check`, etc.)
2. If tests fail, fix them before reporting completion.
3. If the task produced an output document, run `./tools/verify.sh <filepath>`.
   If it fails, fix the output and re-run until all checks pass.
   Do not present the output to the user until verification passes.
4. List all files created or modified in your summary.

## Project Context
<!-- CLAUDE: Ask the user: "What does this project do? What problem does it
     solve, who uses it, and what are the key features?"
     If the project has existing code, scan the codebase first and describe
     what already exists — languages, architecture, key modules, entry points.
     Write 2-3 paragraphs based on what you find and the user's answer.
     DELETE THIS COMMENT after filling in. -->

## Folder Structure
<!-- CLAUDE: After the interview, scan the actual project directory and
     write the real folder structure here. Update this whenever you add
     new top-level folders. DELETE THIS COMMENT after filling in. -->
```
your-project/
├── CLAUDE.md         ← Rules & config (this file)
├── soul.md           ← Agent personality
├── todo.md           ← Project state
├── .env              ← Secrets (never commit)
├── workflows/        ← SOPs and build plans
├── tools/            ← Executable scripts
│   ├── verify.sh     ← Output verification
│   └── heartbeat.sh  ← Proactive monitoring
├── rules/            ← Engineering rules
├── clients/          ← Per-client data
└── templates/        ← Reusable doc templates
```

## Analysis Frameworks
<!-- CLAUDE: Ask the user: "Does your project have specific domain knowledge
     or analysis frameworks I should follow? (e.g., sales methodology,
     medical protocols, legal checklists)" If yes, create named subsections.
     If no, delete this entire section. DELETE THIS COMMENT after resolving. -->

## Hooks
<!-- CLAUDE: Ask the user: "What language(s) will this project use?"
     Based on their answer, set up the appropriate linter/formatter hooks.
     If none apply yet, delete this section and add it later when the
     first code file is created. DELETE THIS COMMENT after resolving. -->

## Style
<!-- CLAUDE: Ask the user: "How should I write code? Any preferences on
     style (simple vs clever), communication (brief vs detailed), or
     libraries to prefer/avoid?" Fill in based on their answer.
     DELETE THIS COMMENT after filling in. -->

## Engineering Rules
Read all files in /rules/ before writing code.

## Self-Awareness
You have permission to modify files in /tools/ and /workflows/ to
improve your own performance. If something isn't working, read your
own source code and fix it.

File map: CLAUDE.md (rules), soul.md (personality), todo.md (state),
/workflows/ (SOPs), /tools/ (scripts), /rules/ (engineering rules).

## Tool Preference
Prefer CLI tools over MCPs. CLIs are composable (pipe through jq, grep, awk).
Use MCPs only for stateful tools (Playwright, database connections).
Build new tools as CLIs first; wrap in MCP only if statefulness is needed.

## Frontend Development
<!-- CLAUDE: Ask the user: "Does this project have a frontend?"
     If no, delete this entire section.
     If yes, keep it, ask about their aesthetic direction, and
     DELETE THIS COMMENT after filling in. -->

When building any user interface:
1. Before writing UI code, ask me about the aesthetic direction
   (minimal, dashboard-heavy, sleek like Linear, dense like Salesforce, etc.)
2. Always load the frontend-design skill before generating HTML,
   React, or Tailwind code.
3. After implementing any UI component, open it in the browser using
   `/chrome`, take a screenshot, and critique your own layout for
   spacing, colors, alignment, and responsiveness.
4. If the user provides a reference screenshot and/or CSS file in
   brand_assets/, use those as the primary design source. Clone the
   layout and style, then adapt the content.
5. Never mark a frontend task complete without a visual verification step.
6. If Figma MCP is configured separately, prefer reading specs from
   Figma over screenshots.
