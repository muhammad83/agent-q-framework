# TDD Workflow — Red-Green-Refactor

## Purpose
Enforces test-driven development discipline for application code tasks.
Ensures every unit of work follows the red-green-refactor cycle with a
mandatory "watch it fail" step.

## When to Use
- Task produces **application code** (business logic, API endpoints, services,
  utilities, data models, UI components)
- Task involves bug fixes where a regression test should be written first

## When NOT to Use
- Config changes (CLAUDE.md, .env, tsconfig, etc.)
- Documentation updates (*.md, README, API docs)
- Workflow/agent definition changes (workflows/, agents/, .claude/commands/)
- Pure refactors where behavior is unchanged and existing tests cover it
- Infrastructure/CI changes

## The Cycle

For each unit of work (one function, one endpoint, one component):

### Step 1 — RED: Write a Failing Test
1. Create or open the test file for the module under development.
2. Write a test that describes the expected behavior.
3. Run the test. **It must fail.** If it passes, the test is not testing
   new behavior -- rewrite it or skip TDD for this unit.
4. Confirm the failure message makes sense (not a syntax error or import
   error, but an actual assertion failure or missing-function error).

### Step 2 — GREEN: Write Minimal Code to Pass
1. Write the **minimum** production code needed to make the failing test pass.
2. Do not add extra logic, optimizations, or edge case handling yet.
3. Run the test. **It must pass.**
4. If it fails, fix the production code (not the test) until it passes.

### Step 3 — REFACTOR: Clean Up
1. With all tests passing, improve the code:
   - Remove duplication
   - Improve naming
   - Simplify logic
   - Extract helpers if needed
2. Run all tests after each refactor step. **They must still pass.**
3. Do not add new behavior during refactor -- that requires a new RED step.

### Step 4 — Repeat
Move to the next unit of work. Start at RED again.

## Anti-Patterns to Avoid

| Anti-Pattern | Why It Fails | Correct Approach |
|---|---|---|
| Writing tests after code | Tests confirm what you wrote, not what you intended | Always write the test first |
| Skipping "too simple" cases | Simple code breaks too; missing tests become gaps | Test it anyway -- simple tests are cheap |
| Mocking everything | Tests pass but nothing actually works end-to-end | Mock only external boundaries (DB, network, filesystem) |
| Writing multiple tests before any code | Loses the tight feedback loop | One test at a time, one pass at a time |
| Making the test pass by hardcoding | Green step is hollow | Write real logic, even if minimal |
| Refactoring while RED | Changing code before the test passes creates confusion | Get to GREEN first, then refactor |

## Integration with Executor

When `/q:execute` runs in TDD mode:
1. Before writing any production code file, create (or identify) the
   corresponding test file.
2. For each function/endpoint/component in the plan:
   a. Write a failing test (RED)
   b. Run tests, confirm failure
   c. Write minimal production code (GREEN)
   d. Run tests, confirm pass
   e. Refactor if needed, run tests again
3. Commit after each completed red-green-refactor cycle (or batch
   related cycles into one commit if they form a logical unit).

## Test File Conventions
- Co-locate tests next to source when the project uses that convention.
- Otherwise, mirror the source tree under a `tests/` or `__tests__/` directory.
- Name test files to match source: `foo.ts` -> `foo.test.ts`, `bar.py` -> `test_bar.py`.
- Follow existing project conventions if they differ from the above.
