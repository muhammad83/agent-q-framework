---
name: q:debug
description: Start a scientific method debugging session
triggers: [debug, fix, error, bug, investigate]
argument-hint: "[description of the bug or error message]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
autonomy: confirm
namespace: quality
---

## Objective
Debug an issue using the scientific method. Track the investigation in a
`DEBUG-{issue}.md` file so progress is preserved across sessions.

## Execution Context
- Read `workflows/debug.md` for the full debugging workflow
- Read `agents/q-debugger.md` for the debugger role definition
- Read `todo.md` for current project state

## Process

1. **Check for active debug files.** Scan for `DEBUG-*.md` in the project root.
   - If found: read it and continue the investigation from where it left off
   - If not found: create a new one

2. **Gather symptoms.** Document in the debug file:
   - What is the expected behavior?
   - What is the actual behavior?
   - Error messages (exact text)
   - When did it start? What changed recently?
   - Steps to reproduce

3. **Form hypothesis.** Based on symptoms, write a specific, testable hypothesis:
   > "I believe [X] is causing [Y] because [Z]"

4. **Investigate.** Test the hypothesis:
   - Read relevant code
   - Add targeted logging or breakpoints
   - Run the code and observe
   - Document findings in the debug file

5. **Iterate.** If hypothesis was wrong:
   - Document what you learned
   - Form a new hypothesis
   - Repeat (max 3 hypotheses before escalating)

6. **Fix.** When root cause is found:
   - Implement the fix
   - Verify the fix resolves the issue
   - Check for regressions
   - Update the debug file with resolution

7. **Human verification.** Before marking resolved, present:
   - Root cause
   - The fix applied
   - How it was verified
   - Ask user to confirm

8. **Clean up.** After user confirms:
   - Commit the fix: `fix({scope}): {description}`
   - Move `DEBUG-{issue}.md` details into `todo.md` → Completed
   - Delete or archive the debug file

## Success Criteria
- Root cause identified and documented
- Fix implemented and verified
- No regressions introduced
- User confirmed the fix
- Debug file cleaned up
