# Workflow: Scientific Method Debugging

## Trigger
Run this when:
- A bug is reported or discovered
- Tests are failing with unclear cause
- Behavior doesn't match expectations
- User runs `/q:debug`

## Context Needed
Before running, make sure you have:
- [ ] Description of the bug or error message
- [ ] Access to the relevant source code
- [ ] Ability to run the code and see output

## Steps

1. **Check for active debug files.** Scan project root for `DEBUG-*.md`.
   - If found: read it. Are we resuming an investigation? Continue from where it stopped.
   - If not: proceed to step 2.

2. **Create debug file.** Create `DEBUG-{issue-slug}.md` in project root with
   the format specified in `agents/q-debugger.md`.

3. **Gather symptoms.** Fill in the Symptoms section:
   - Expected behavior
   - Actual behavior
   - Exact error messages
   - Steps to reproduce
   - Recent changes (check `git log --oneline -10`)

4. **Form hypothesis.** Write a specific, testable hypothesis:
   > "I believe {X} is causing {Y} because {Z}."

5. **Test hypothesis.**
   - Read relevant source code
   - Add targeted logging if needed
   - Run the code and observe
   - Document findings in the debug file

6. **Iterate or fix.**
   - If confirmed: implement the fix, update debug file
   - If refuted: document what you learned, form new hypothesis
   - Max 3 hypotheses. After 3 failures: escalate to user with findings.

7. **Verify fix.**
   - Run the original reproduction steps — does the bug still occur?
   - Run the full test suite — any regressions?
   - Check edge cases related to the fix

8. **Human verification.** Present to the user:
   - Root cause found
   - Fix applied
   - Verification performed
   - Ask: "Does this look correct? Can I mark this resolved?"

9. **Clean up** after user confirms:
   - Commit: `fix({scope}): {description of root cause fix}`
   - Log resolution in `todo.md`
   - Archive or delete the `DEBUG-*.md` file

## Tools Used
- `agents/q-debugger.md` — role definition and debug file format
- Git — check recent changes, commit fix
- Test runner — verify fix and check regressions

## Output
- `DEBUG-{issue}.md` tracking file (temporary, deleted after resolution)
- Fix committed with `fix()` prefix
- `todo.md` updated

## Success Criteria
- Root cause identified (not just symptoms treated)
- Fix verified against original reproduction steps
- No regressions in test suite
- User confirmed resolution
- Debug file cleaned up

## Edge Cases
- **Can't reproduce** — document what you tried. Ask user for more details
  or access to the environment where it occurs.
- **Multiple bugs** — create separate `DEBUG-*.md` files for each. Fix one
  at a time.
- **Pre-existing bug** — if the bug existed before current work, log it in
  `todo.md` → Known Issues and move on (per deviation rules).
- **Intermittent bug** — add extra logging, run multiple times, look for
  race conditions or timing-dependent behavior.
