# Agent Q — Rules

## Rules
1. Before starting any task, read todo.md for current project state.
2. After completing any task, update todo.md with what was done.
3. You are expected to edit all files in this project, including your own config file.
   If the user corrects a behavior during a session, update your config file to prevent recurrence.
4. Keep all workflow instructions in /workflows as .md files.
5. Keep all executable scripts in /tools.
6. Never store secrets in code. Use .env files.
7. When unsure about a decision, ask — don't guess.
8. Follow the Planning Protocol (context/planning-protocol.md) before writing code for multi-file changes or new features.
9. 2-Strike Rule: If the user corrects you twice on the same mistake,
   stop and ask for clarification rather than guessing again.

## Plan Storage
Save implementation plans to `workflows/build-plan-{feature-name}.md`. Never save plans to `~/.claude/plans/` — this causes drift. Plans must live in the project repo so they are tracked in git and reviewable.

## Verification
After completing any build task:
1. Run any existing tests (`pytest`, `ruff check`, etc.)
2. If tests fail, fix them before reporting completion.
3. If the task produced an output document, run `./tools/verify.sh <filepath>`.
   If it fails, fix the output and re-run until all checks pass.
   Do not present the output to the user until verification passes.
4. List all files created or modified in your summary.

## Documentation
After completing any build task that adds, removes, or changes:
- A public API endpoint or CLI command → update the relevant docs
  (README.md, API.md, or usage section)
- A file in tools/ or workflows/ → update its header comment and
  the file map in README.md
- The folder structure → update the directory tree in README.md
- A configuration option or env variable → update .env.example
  and any setup docs

Never mark a task complete without checking if documentation
needs updating. When in doubt, update the docs.

## Deviation Rules

When executing a build plan, you will encounter issues that weren't anticipated.
Use these rules to decide whether to auto-fix or stop and ask.

**Rule 1: Auto-fix bugs.** Broken behavior, errors, logic errors, typos in code.
Fix immediately. No need to ask.

**Rule 2: Auto-add missing critical functionality.** Validation, error handling,
security checks, null guards. If the code would fail without it, add it.

**Rule 3: Auto-fix blocking issues.** Missing dependencies, wrong types, build
errors, import failures. Fix whatever is preventing forward progress.

**Rule 4: STOP for architectural changes.** New database tables, switching
frameworks, breaking public APIs, changing data models, adding new services.
These require user approval. Stop and explain what you want to change and why.

Rules 1-3 have a **3-attempt limit**. If you can't fix an issue in 3 tries,
stop and report it. If the issue is pre-existing (not caused by your changes),
log it under `todo.md` → Known Issues and move on.

Rule 4 always stops. No exceptions.

## Analysis Paralysis Guard

If you make **5+ consecutive Read/Grep/Glob calls** without any Edit/Write/Bash
action: **STOP**. State what you've learned and why you haven't written code yet.
Either write code or report "blocked on [reason]."

Reading is not progress. Writing is progress.

## Atomic Commits

After completing each discrete task (not at the end of a session — after each task):

1. Stage files individually — never use `git add .` or `git add -A`
2. Commit with format: `{type}({scope}): {description}`
   - Types: `feat`, `fix`, `test`, `refactor`, `chore`, `docs`
   - Example: `feat(auth): add JWT token refresh endpoint`
3. Keep commits small and focused — one logical change per commit
