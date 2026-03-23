---
name: q:tdd
description: Execute a task using strict TDD (red-green-refactor) discipline
triggers: [tdd, test first, test driven, red green refactor]
argument-hint: "[task description or build-plan reference]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
autonomy: confirm
namespace: execution
---

## Objective
Execute a coding task using strict test-driven development. Every unit of work
follows the red-green-refactor cycle. No production code is written until a
failing test exists for it.

## Execution Context
- Read `workflows/tdd.md` for the full TDD workflow and anti-patterns
- Read `context/rules.md` for deviation rules and commit format
- Read `context/engineering-preferences.md` for coding standards
- Read `todo.md` for current project state

## Process

1. **Load context.** Read `workflows/tdd.md`, `context/rules.md`, and
   `context/engineering-preferences.md`.

2. **Identify scope.** Determine which units of work (functions, endpoints,
   components) need to be built. If a build plan is referenced, read it.

3. **Check applicability.** TDD applies only to application code. If the task
   is config, docs, or workflow changes, inform the user and suggest using
   `/q:execute` instead.

4. **For each unit of work, follow the cycle:**

   a. **RED** -- Write a test that describes expected behavior.
      - Create or open the test file.
      - Write one test case.
      - Run the test suite. Confirm it **fails**.
      - If it passes unexpectedly, reassess -- the behavior may already exist.

   b. **GREEN** -- Write the minimum production code to pass.
      - Create or open the source file.
      - Write only enough code to make the failing test pass.
      - Run the test suite. Confirm it **passes**.
      - Do not add extra logic beyond what the test requires.

   c. **REFACTOR** -- Clean up with tests green.
      - Improve naming, remove duplication, simplify.
      - Run tests after each change. They must stay green.
      - Do not add new behavior (that needs a new RED step).

5. **Commit.** After completing each red-green-refactor cycle (or a logical
   batch of related cycles), stage files individually and commit:
   `{type}({scope}): {description}`

6. **Repeat** until all units of work are complete.

7. **Update todo.md** with progress.

## Guardrails
- **Refuse to write production code if no failing test exists.** This is the
  core discipline. If you catch yourself writing code first, stop, delete it,
  and write the test.
- **One test at a time.** Do not batch-write multiple tests before coding.
- **Mock only boundaries.** External services, databases, filesystem -- mock
  those. Internal logic gets real tests.
- Follow the anti-pattern list in `workflows/tdd.md`.

## Success Criteria
- Every piece of production code has a corresponding test written before it
- All tests pass
- Red-green-refactor cycle followed for each unit of work
- No production code exists without a test that drove its creation
- `todo.md` updated with completed work
