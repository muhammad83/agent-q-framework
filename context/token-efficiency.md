# Agent Q — Token Efficiency Rules

Rules for conserving context when usage crosses 50%. These rules activate
automatically based on the context budget zones defined in
`context/planning-protocol.md`.

## When to Activate

Activate these rules when context usage enters **DEGRADING** (50-70%) or
**POOR** (70%+) zones. The deeper into these zones, the more aggressively
you should apply every rule below.

| Zone | Severity | Behavior |
|---|---|---|
| DEGRADING (50-70%) | Moderate | Apply all rules below. Finish current task set, then commit. |
| POOR (70%+) | Critical | Apply all rules aggressively. Stop after current task, commit, `/compact` or `/clear`. |

## When NOT to Activate

In **PEAK** (0-30%) and **GOOD** (30-50%) zones, follow normal engineering
preferences from `context/engineering-preferences.md`. Specifically:

- Thoroughness over speed
- Handle more edge cases, not fewer
- Explicit over clever
- Full explanations when they add value

Do not sacrifice quality for token savings when context budget is healthy.

## Rules

### 1. Batch Tool Calls
Never make sequential tool calls that could be parallel. If you need to read
3 files, read all 3 in one response. If you need to search and read, combine
independent calls.

### 2. Prefer Glob/Grep Over Broad Exploration
Use `Glob` and `Grep` with targeted patterns instead of open-ended browsing.
Avoid reading entire files when you only need a specific section — use `offset`
and `limit` parameters on `Read`.

### 3. Skip Redundant Reads
If you already read a file in this session, do not read it again. Track what
you have seen. If you need to verify a specific line, use `Grep` with a narrow
pattern instead of re-reading the whole file.

### 4. Compact Handoff Payloads
When handing off to subagents or summarizing for the user:
- Bullet points, not paragraphs
- File paths and line numbers, not quoted code blocks
- Decisions and outcomes, not the reasoning chain

### 5. Terse Output Style
- Drop verbose explanations. State what you did and what happened.
- No preamble ("Let me...", "I'll now..."). Just do it.
- No restating the user's request back to them.
- Summaries: 3-5 bullet points max.

### 6. Proactive `/compact` Usage
- At 50%: evaluate whether `/compact` would help.
- At 60%: strongly consider `/compact` after committing current work.
- At 70%+: `/compact` or `/clear` immediately after committing.

### 7. Commit Frequently
Do not accumulate uncommitted work. Each completed task gets an immediate
atomic commit. This protects progress and enables context resets without
losing work.

### 8. Minimize File Writes
Prefer `Edit` (sends only the diff) over `Write` (sends entire file content).
Only use `Write` for new files or complete rewrites.

### 9. Drop Low-Value Work
In POOR zone, skip:
- Documentation updates that can be done in a follow-up session
- Optional refactoring that isn't in the current plan
- Exploratory reads "just to understand" — stay focused on the task

### 10. One-Shot Edits
Plan your edit before making it. Do not make multiple small edits to the same
file when one well-planned edit would suffice. Each tool call costs context.
