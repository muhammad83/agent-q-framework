---
name: q:execute
description: Execute a build plan with deviation rules and atomic commits
triggers: [execute, build, implement, run plan, code]
argument-hint: "[build-plan filename or feature name]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
autonomy: confirm
namespace: execution
---

## Objective
Execute a build plan from `workflows/build-plan-{feature}.md` following deviation
rules and atomic commit conventions.

## Execution Context
- Read `context/rules.md` for deviation rules and atomic commit format
- Read `context/engineering-preferences.md` for coding standards
- Read `todo.md` for current state
- If TDD mode is requested, also read `workflows/tdd.md`

## Process

1. **Load plan.** Read the specified build plan file. If no argument given,
   check `todo.md` for the active plan reference.

2. **Load rules.** Read `context/rules.md` (deviation rules, atomic commits)
   and `context/engineering-preferences.md`.

3. **Check for TDD mode.** If the argument includes `--tdd` or the plan
   specifies TDD mode, load `workflows/tdd.md` and follow the red-green-refactor
   cycle for all application code tasks. TDD applies only to application code --
   config, docs, and workflow changes skip TDD and proceed normally.

4. **Execute tasks sequentially.** For each task in the plan:
   a. Mark task as in-progress in `todo.md`
   b. If TDD mode is active and the task produces application code,
      follow the red-green-refactor cycle from `workflows/tdd.md`:
      write failing test first, then minimal code to pass, then refactor.
   c. Build exactly what the plan specifies
   d. Apply deviation rules:
      - Rules 1-3: auto-fix bugs, missing functionality, blocking issues (3-attempt limit)
      - Rule 4: STOP for architectural changes -- ask user
   e. After completing the task, stage files individually and commit:
      `{type}({scope}): {description}`
   f. Mark task as complete in `todo.md`

5. **Respect the analysis paralysis guard.** If you make 5+ consecutive
   Read/Grep/Glob calls without writing code, stop and state why.

6. **Monitor context budget.** If context usage feels high (responses getting
   longer, losing track of details), commit current work and suggest `/compact`.

7. **Run verification.** After all tasks: run tests, `./tools/verify.sh` if
   applicable, and list all files created/modified.

## Success Criteria
- All plan tasks completed and committed individually
- Deviation rules followed (auto-fixes logged, architectural changes escalated)
- `todo.md` updated with completed tasks
- All tests pass
- Files created/modified listed in summary
