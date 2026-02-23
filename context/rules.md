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
Save implementation plans to `workflows/build-plan-{feature-name}.md`. Plans must live in the project repo so they are tracked in git and reviewable.

## Verification
After completing any build task:
1. Run any existing tests (`pytest`, `ruff check`, etc.)
2. If tests fail, fix them before reporting completion.
3. If the task produced an output document, run `./tools/verify.sh <filepath>`.
   If it fails, fix the output and re-run until all checks pass.
   Do not present the output to the user until verification passes.
4. List all files created or modified in your summary.
