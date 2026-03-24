---
name: review-pr
description: >
  Pre-landing PR review. Analyzes the branch diff against the base branch for
  structural issues that tests do not catch: SQL safety, trust boundary
  violations, conditional side effects, race conditions, enum completeness,
  and test coverage gaps. Supersedes the simpler code-review.md workflow.
autonomy: semi-autonomous
namespace: review
triggers:
  - user asks for "PR review", "code review", "pre-landing review", "check my diff"
  - user is about to merge or land code changes
---

# Workflow: Pre-Landing PR Review

## Trigger
Run this when the user has code changes ready to land and wants a structural
review of the diff. This reviews the actual code diff, not a plan.

## Context Needed
Before running, make sure you have:
- [ ] Current branch is not the base branch (main/master)
- [ ] There are changes to review (diff is not empty)
- [ ] `todo.md` for project state
- [ ] `agents/q-reviewer.md` for report format and severity levels

## Steps

### Step 1: Check Branch
1. Get the current branch name.
2. Detect the base branch (check PR target, then repo default, fallback to main).
3. If on the base branch or no diff exists: "Nothing to review." Stop.
4. Fetch latest base branch to avoid stale false positives.

### Step 2: Scope Drift Detection
Before reviewing code quality, check: did they build what was requested?

1. Read todo.md and commit messages for the branch.
2. Identify the **stated intent** — what was this branch supposed to accomplish?
3. Compare files changed against stated intent.
4. Evaluate:
   - **Scope creep:** files changed unrelated to stated intent, "while I was in
     there" changes, new features not in the plan.
   - **Missing requirements:** requirements not addressed in the diff, test
     coverage gaps, partial implementations.
5. Output:
   ```
   Scope Check: [CLEAN / DRIFT DETECTED / REQUIREMENTS MISSING]
   Intent: <1-line summary of what was requested>
   Delivered: <1-line summary of what the diff actually does>
   ```
6. This is informational — does not block the review. Proceed.

### Step 3: Get the Diff
Run `git diff origin/{base}` to get the full diff including both committed and
uncommitted changes against the latest base branch.

### Step 4: Two-Pass Review
Apply the review checklist against the diff in two passes.

**Pass 1 — CRITICAL (must fix before landing):**

1. **SQL and Data Safety**
   - Raw SQL with string interpolation (SQL injection)
   - Migrations that lock tables in production (large table ALTER)
   - Missing WHERE clause on UPDATE/DELETE
   - Unindexed queries on large tables

2. **Race Conditions and Concurrency**
   - Read-then-write without locking
   - Shared mutable state across threads/requests
   - Optimistic locking without conflict handling
   - Background jobs that assume single-execution

3. **Trust Boundary Violations**
   - User input passed directly to system commands
   - External API responses used without validation
   - LLM output treated as trusted data (used in SQL, HTML, or auth decisions
     without sanitization)
   - Deserialization of untrusted data

4. **Enum and Value Completeness**
   - When the diff introduces a new enum value, status, tier, or type constant:
     search ALL files that reference sibling values and verify the new value is
     handled everywhere. This requires reading code OUTSIDE the diff.

**Pass 2 — INFORMATIONAL (should fix, not blocking):**

5. **Conditional Side Effects**
   - Side effects (DB writes, API calls, emails) inside conditional branches
     where the condition could be false more often than expected
   - Side effects in error handlers that could throw their own errors

6. **Magic Numbers and String Coupling**
   - Hardcoded values that should be constants
   - String matching for logic (e.g., `if status == "active"`)

7. **Dead Code and Consistency**
   - Commented-out code with no explanation
   - Inconsistent patterns (one place uses pattern A, new code uses pattern B)

8. **Test Gaps**
   - Changed code paths without corresponding test changes
   - New branches (if/else, switch) without test coverage
   - Error handlers without tests that trigger them

9. **Performance and Bundle Impact**
   - New dependencies: what is the size/weight?
   - N+1 query patterns in new code
   - Synchronous operations that could be async

### Step 5: Test Coverage Audit
For each changed file, trace the codepaths modified and check for test coverage:

1. Diagram changed code paths (functions, branches, error handlers).
2. Search for tests covering each path.
3. Produce ASCII coverage diagram (same format as review-eng.md Section 4).
4. If test framework is detected and gaps exist, note specific tests to write.
5. Regression rule: if existing behavior was modified and no test covers the
   change, flag as CRITICAL.

### Step 6: Documentation Staleness Check
Cross-reference the diff against documentation files. If code changed but
documentation describing that code was not updated in this branch, flag as
informational.

### Step 7: Fix-First Review
Every finding gets action, not just critical ones.

1. **Classify** each finding as AUTO-FIX (mechanical, obvious fix) or ASK
   (needs user judgment).
2. **Auto-fix** all AUTO-FIX items. Output one-line summary per fix.
3. **Batch-ask** about remaining ASK items: present each with severity,
   problem description, recommended fix, and options (A: Fix, B: Skip).
4. **Apply** user-approved fixes.

### Step 8: Verification of Claims
Before producing the final output:
- If you claim "this is safe" — cite the specific line proving safety.
- If you claim "handled elsewhere" — read and cite the handling code.
- If you claim "tests cover this" — name the test file and method.
- Never say "likely handled" or "probably tested" — verify or flag as unknown.

### Step 9: todo.md Cross-Reference
- Does this PR close any open TODOs? Note which.
- Does this PR create work that should become a TODO? Flag it.
- Are there related TODOs that provide context? Reference them.

### Step 10: Final Output
```
PRE-LANDING REVIEW: {branch name}
====================================
Base: {base branch}
Diff: {N} files changed, {insertions}+/{deletions}-

Scope Check: {CLEAN / DRIFT / MISSING}

CRITICAL FINDINGS:
1. [{category}] {file}:{line} — {description}
   Fix: {what to do}
...

INFORMATIONAL FINDINGS:
1. [{category}] {file}:{line} — {description}
   Fix: {what to do}
...

AUTO-FIXED: {count}
USER-DECIDED: {count} ({fixed}/{skipped})

TEST COVERAGE: {X}/{Y} changed paths tested ({percent}%)

VERDICT: {PASS / PASS WITH WARNINGS / FAIL}
```

## Tools Used
- Git commands for diff, branch detection, and log
- File reading tools for code outside the diff (enum completeness)
- Search tools for test coverage analysis

## Output
- Structured review report
- Auto-fixed code changes (if any)
- Updated todo.md if applicable

## Success Criteria
- Both passes (critical + informational) completed
- Scope drift detection reported
- No unresolved CRITICAL findings
- Test coverage audit produced
- Every finding has an action (fix or acknowledged skip)
- Claims verified with evidence, not assumptions

## Edge Cases
- Diff is test-only changes: skip test coverage audit ("No new application code
  paths to audit") but still run both review passes on the test code.
- Diff is huge (500+ files): focus Pass 1 only, note that Pass 2 was skipped
  due to size.
- No test framework detected: still produce coverage diagram, skip test generation.
- Branch has no PR yet: use commit messages and todo.md for stated intent.
