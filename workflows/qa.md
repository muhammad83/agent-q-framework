# Workflow: QA (Code-Level)

## Trigger
Run this when the user wants a quality audit of their code: interaction state
coverage, edge case analysis, error path coverage, input validation audit.
This is code-level QA only -- no browser testing.

## Context Needed
Before running, make sure you have:
- [ ] Target scope (specific files, a feature, or the full diff)
- [ ] `CLAUDE.md` for project context and test commands
- [ ] `todo.md` for known issues

## Modes

| Mode | When to use | Scope |
|------|-------------|-------|
| **Quick** | Smoke check, small changes | Critical + High severity only |
| **Standard** | Default for most PRs | + Medium severity |
| **Exhaustive** | Pre-release, critical features | + Low/cosmetic issues |

Default: **Standard**. Override with argument: `--quick` or `--exhaustive`.

## Steps

### Step 0: Scope detection

1. **If on a feature branch with no specific scope given:** Enter diff-aware mode.
   ```
   git diff main...HEAD --name-only
   git log main..HEAD --oneline
   ```
   Scope the QA audit to files changed on this branch.

2. **If the user specifies files or a feature:** Scope to those files.

3. **If on main or no diff:** Audit the full codebase (or ask the user for scope).

---

### Step 1: Build interaction state coverage map

For each feature or component in scope, build a matrix of states:

| Feature | Loading | Empty | Error | Success | Partial |
|---------|---------|-------|-------|---------|---------|
| Feature A | ? | ? | ? | ? | ? |
| Feature B | ? | ? | ? | ? | ? |

For each cell, read the code and determine:
- **Handled:** Code explicitly handles this state (mark with a checkmark).
- **Missing:** No handling exists (mark as GAP).
- **Partial:** Some handling but incomplete (mark as WARN).

**How to detect states:**
- **Loading:** Look for async operations, spinners, loading flags, skeleton states.
- **Empty:** Look for zero-result handling, empty array checks, null guards.
- **Error:** Look for try/catch, error boundaries, .catch(), rescue blocks, error states.
- **Success:** Look for the happy path rendering/response.
- **Partial:** Look for pagination, partial loads, graceful degradation.

---

### Step 2: Edge case matrix

For each function or endpoint in scope, identify edge cases:

| Function | Input | Edge Case | Handled? |
|----------|-------|-----------|----------|
| `createUser()` | email | Empty string | ? |
| `createUser()` | email | Invalid format | ? |
| `createUser()` | email | Duplicate | ? |
| `processPayment()` | amount | Zero | ? |
| `processPayment()` | amount | Negative | ? |
| `processPayment()` | amount | Overflow | ? |

**Common edge cases to check:**
- Null/undefined/empty inputs
- Boundary values (0, -1, MAX_INT, empty string, max-length string)
- Duplicate submissions / idempotency
- Concurrent access / race conditions
- Unicode and special characters
- Very large inputs (arrays, strings, files)
- Missing required fields
- Type mismatches

---

### Step 3: Error path coverage

Trace every error path in the changed code:

1. **Find all error origins:** try/catch, .catch(), rescue, error returns, throw/raise.
2. **Trace propagation:** Does the error bubble up? Is it caught? Is it swallowed?
3. **Check user impact:** Does the user see a useful message or a cryptic failure?

For each error path, classify:
- **Handled well:** Error caught, user gets clear feedback, system recovers.
- **Handled poorly:** Error caught but swallowed, generic message, no recovery.
- **Unhandled:** Error can occur but nothing catches it.

---

### Step 4: Input validation audit

For every user-facing input (API parameters, form fields, CLI arguments, config values):

1. **Check server-side validation exists.** Client-side only is insufficient.
2. **Check validation completeness:**
   - Type checking (string vs number vs boolean)
   - Length/range limits
   - Format validation (email, URL, date)
   - Allowlist/denylist for enums
   - SQL injection / XSS prevention
   - Path traversal prevention
3. **Check error messages are user-friendly** (not stack traces or internal errors).

---

### Step 5: Compute health score

Score each category from 0-100, then compute the weighted average.

**Scoring per category:**
- Start at 100.
- Critical issue: -25
- High issue: -15
- Medium issue: -8
- Low issue: -3
- Minimum: 0.

**Weights:**

| Category | Weight |
|----------|--------|
| Interaction states | 20% |
| Edge cases | 20% |
| Error handling | 25% |
| Input validation | 20% |
| Code consistency | 15% |

**Final score:** `score = sum(category_score * weight)`

---

### Step 6: Generate report

Write a structured report to `qa-report-{branch}-{YYYY-MM-DD}.md`:

```markdown
# QA Report: {branch}
Date: {YYYY-MM-DD}
Mode: {Quick|Standard|Exhaustive}
Scope: {files/features audited}
Health Score: {N}/100

## Summary
- {top 3 issues to fix}

## Interaction State Coverage
{matrix from Step 1}

## Edge Cases
{matrix from Step 2}

## Error Path Coverage
{findings from Step 3}

## Input Validation
{findings from Step 4}

## Issue List
| # | Severity | Category | Description | File:Line |
|---|----------|----------|-------------|-----------|
| 1 | Critical | ... | ... | ... |

## Recommendations
- {prioritized list of fixes}
```

**Severity tiers by mode:**
- **Quick:** Report Critical and High only. Skip Medium and Low.
- **Standard:** Report Critical, High, and Medium. Skip Low.
- **Exhaustive:** Report all severities including Low/cosmetic.

---

### Step 7: Update state

Update `todo.md` with QA results: health score, critical findings count, report path.

## Tools Used
- git (diff, log, branch)
- Project source files (Read, Grep, Glob)

## Output
- QA report file: `qa-report-{branch}-{YYYY-MM-DD}.md`
- `todo.md` updated with QA results

## Success Criteria
- Interaction state coverage map built for all in-scope features
- Edge case matrix populated for all in-scope functions
- Error paths traced and classified
- Input validation audited for all user-facing inputs
- Health score computed with category breakdown
- Structured report generated
- Critical/High issues clearly prioritized

## Edge Cases
- **No feature branch:** Ask user for scope or audit full codebase
- **Very large diff:** Cap at the 20 most-changed files. Note: "Scope capped. Run
  again with specific file paths for deeper coverage."
- **No user-facing inputs:** Skip Step 4, note "No user-facing inputs in scope"
- **Test-only changes:** Simplify to: "Changes are test-only. No QA gaps detected."
- **Config/infra changes:** Focus on edge cases and error handling, skip interaction states
