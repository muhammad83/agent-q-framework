# Build Plan B: Error & Deviation Upgrade

## Goal
Replace flat deviation rules with a structured error hierarchy that maps error types to auto-fix strategies and debug workflows. Add status tracking to orchestration handoffs.

## Discovery Level
Level 1 — Quick verify on existing deviation rule usage.

## Tasks

### Task 1: Hierarchical Error Taxonomy in rules.md
Replace the current flat deviation rules (Rules 1-4) in `context/rules.md` with a structured error tree.

**Error Hierarchy:**

```
AgentQError (base)
├── BuildError (blocks forward progress)
│   ├── DependencyError — missing package, wrong version
│   ├── ImportError — module not found, circular import
│   ├── TypeErrors — wrong types, missing args
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

**Mapping to deviation rules:**

| Error Type | Action | Auto-fix Limit |
|------------|--------|---------------|
| BuildError | Auto-fix | 3 attempts |
| LogicError (Bug, Validation) | Auto-fix | 3 attempts |
| LogicError (Security) | Auto-fix + flag to user | 1 attempt |
| ArchitecturalError | STOP — user approval required | 0 |
| EnvironmentError | Log + skip if non-blocking | 2 attempts |

**Debug workflow mapping:**

| Error Type | Debug Strategy |
|------------|---------------|
| BuildError | Check imports → check versions → check types |
| LogicError | Hypothesis-driven (scientific method from debug.md) |
| ArchitecturalError | N/A — escalate to user |
| EnvironmentError | Check connectivity → check permissions → check resources |

### Task 2: Status Tracking for Orchestration Handoffs
Update `workflows/orchestration-protocol.md` to add status fields to handoff format.

**Updated handoff format:**

```
## HANDOFF: [previous-agent] → [next-agent]
### Status: pending | running | done | failed
### Started: [timestamp]
### Completed: [timestamp]
### Context
### Findings
### Files Modified
### Error Classification (if failed)
### Open Questions
### Recommendations
```

Add polling section to orchestration protocol:
- Orchestrator checks handoff status every phase
- If `failed` + error classification is BuildError/LogicError → route to debugger
- If `failed` + ArchitecturalError → verdict = BLOCKED

## Files

| Action | File |
|--------|------|
| Modify | `context/rules.md` — replace Deviation Rules section |
| Modify | `workflows/orchestration-protocol.md` — update handoff format |
| Modify | `agents/q-debugger.md` — add error classification to debug workflow |

## Edge Cases
- Existing deviation rules referenced elsewhere — search for "Rule 1", "Rule 2" etc. and update references
- Orchestration protocol may not exist yet — create if missing

## Verification
- `context/rules.md` has the full error hierarchy and mapping tables
- Handoff format in orchestration protocol includes status fields
- q-debugger references error classification
- No broken references to old Rule 1-4 numbering

## Rollback
Revert `context/rules.md`, `workflows/orchestration-protocol.md`, and `agents/q-debugger.md` from git.
