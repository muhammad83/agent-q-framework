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

## Deviation Rules — Error Taxonomy

When executing a build plan, classify unexpected issues using this hierarchy
to determine the correct response.

### Error Hierarchy

```
AgentQError (base)
├── BuildError (blocks forward progress)
│   ├── DependencyError — missing package, wrong version
│   ├── ImportError — module not found, circular import
│   ├── TypeError — wrong types, missing args
│   └── CompileError — syntax errors, build failures
├── LogicError (wrong behavior)
│   ├── BugError — broken functionality, wrong output
│   ├── ValidationError — missing guards, bad input handling
│   └── SecurityError — injection, XSS, auth bypass
├── ArchitecturalError (structural change needed)
│   ├── SchemaChange — new tables, data model changes
│   ├── APIChange — breaking public interface
│   └── ServiceChange — new service, framework swap
└── EnvironmentError (external)
    ├── NetworkError — API down, timeout
    ├── PermissionError — file access, auth token expired
    └── ResourceError — disk full, memory limit
```

### Response Rules

| Error Type | Action | Auto-fix Limit |
|------------|--------|---------------|
| BuildError | Auto-fix immediately | 3 attempts |
| LogicError (Bug, Validation) | Auto-fix immediately | 3 attempts |
| LogicError (Security) | Auto-fix + flag to user | 1 attempt |
| ArchitecturalError | **STOP** — user approval required | 0 (always stop) |
| EnvironmentError | Log + skip if non-blocking | 2 attempts |

After exhausting auto-fix attempts, log the issue under `todo.md` → Known Issues
and move on if the issue is non-blocking. If blocking, stop and report.

Pre-existing issues (not caused by your changes) go directly to Known Issues.

### Debug Strategy by Error Type

| Error Type | Strategy |
|------------|----------|
| BuildError | Check imports → check versions → check types → check build config |
| LogicError | Hypothesis-driven scientific method (see `workflows/debug.md`) |
| ArchitecturalError | N/A — escalate to user for decision |
| EnvironmentError | Check connectivity → check permissions → check resources |

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

## Language-Specific Rules
Load the relevant language rules based on the project's tech stack:
- TypeScript/JavaScript projects → also read `context/rules-typescript.md`
- Python projects → also read `context/rules-python.md`
