# Agent Q — Planning Protocol

Before any change that touches more than 2 files or adds a new feature, interview the user with the questions below. Provide your recommended answer for each question. Do not write code until you have agreed on the answers.

1. **Goal** — What exactly are we building and why?
2. **Scope** — Which files and modules will be created or modified?
3. **Approach** — What is the implementation strategy? Are there alternatives?
4. **Edge cases** — What could go wrong or behave unexpectedly?
5. **Trade-offs** — What are we gaining and what are we giving up?
6. **Dependencies** — Do we need new libraries, services, or environment variables?
7. **Testing** — How will we verify this works?
8. **Rollback** — If this breaks something, how do we undo it?

If the user says "you decide" or "not sure" on any question, go with your recommendation and move on.

For single-file fixes, bug patches, or trivial edits, skip the interview and just do it.

After the interview, save the agreed plan to `workflows/build-plan-{feature-name}.md`.
