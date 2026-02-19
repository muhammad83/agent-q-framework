# CLAUDE.md — [PROJECT NAME]

## Role
<!-- Your role goes here. Keep it to 1-2 lines.
     For personality, tone, and identity — see soul.md instead. -->
You are [DESCRIBE THE AGENT'S ROLE IN ONE SENTENCE].
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
3. List all files created or modified in your summary.

## Project Context
[DESCRIBE WHAT THIS PROJECT DOES IN 2-3 PARAGRAPHS. INCLUDE:
- What problem it solves
- Who uses it
- What the key features are]

## Analysis Frameworks
[DELETE THIS SECTION IF NOT APPLICABLE. OTHERWISE REPLACE WITH
YOUR PROJECT'S DOMAIN EXPERTISE. EXAMPLES:]

### Framework 1: [NAME]
- [Key question this framework answers]
- [Key question this framework answers]
- [Key question this framework answers]

### Framework 2: [NAME]
- [Key question this framework answers]
- [Key question this framework answers]
- [Key question this framework answers]

## Folder Structure
[UPDATE THIS TO MATCH YOUR ACTUAL STRUCTURE]
```
your-project/
├── CLAUDE.md
├── todo.md
├── .env
├── workflows/
├── tools/
└── [any project-specific folders]
```

## Hooks
[ADD AUTO-RUN COMMANDS HERE. DELETE IF NOT NEEDED YET.]
- After writing any .py file, run: ruff check <filename>
- After writing any .js file, run: npm run lint

## Style
- [HOW SHOULD CLAUDE WRITE CODE? e.g. "Simple over clever"]
- [HOW SHOULD CLAUDE COMMUNICATE? e.g. "Direct and specific"]
- [ANY LIBRARIES TO PREFER OR AVOID?]

## Engineering Rules
Read all files in /rules/ before writing code.

## Verification
After generating any output document, run `./tools/verify.sh <filepath>`.
If it fails, fix the output and re-run until all checks pass.
Do not present the output to the user until verification passes.

## Self-Awareness
You are running as Claude Code in this project directory.
Your engineering rules are in CLAUDE.md (this file).
Your personality and identity are in soul.md.
Your task state is in todo.md.
Your workflows are in /workflows/.
Your tools are in /tools/.
Your rules are in /rules/.

If something isn't working, read your own source code and fix it.
You have permission to modify files in /tools/ and /workflows/ to
improve your own performance.

Prioritize names and structures that are easy for agents to discover
over personal preference. If the name is in the weights, keep it.

## Tool Preference
Prefer CLI tools over MCPs where possible.
CLIs are composable — you can pipe through jq, grep, awk to extract
only what you need before loading it into context.
MCPs dump full response blobs that pollute your context window.

Use MCPs only for stateful tools (Playwright, database connections)
where a persistent session is required.

When building new tools, build them as CLIs first.
Wrap in MCP only if statefulness is genuinely needed.

## Frontend Development
> **This section only applies if this project has a frontend.**
> Delete this entire section for backend-only projects.

When building any user interface:
1. Before writing UI code, ask me about the aesthetic direction
   (minimal, dashboard-heavy, sleek like Linear, dense like Salesforce, etc.)
2. Always load the frontend-design skill before generating HTML,
   React, or Tailwind code.
3. After implementing any UI component, open it in the browser using
   `/chrome`, take a screenshot, and critique your own layout for
   spacing, colors, alignment, and responsiveness.
4. If I provide a Figma file or reference screenshot, compare your
   output against it pixel-by-pixel before marking it done.
5. Never mark a frontend task complete without a visual verification step.
6. If Figma MCP is configured, read design specs directly from Figma
   rather than asking me to describe them.
