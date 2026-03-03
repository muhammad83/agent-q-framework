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

## Context Budget Awareness

Your context window is finite. Quality degrades as it fills up. Plan accordingly.

| Context Used | Zone | Behavior |
|---|---|---|
| 0-30% | PEAK | Full capability. Do your best work here. |
| 30-50% | GOOD | Still strong. Finish current task set. |
| 50-70% | DEGRADING | Start missing details. Wrap up and commit. |
| 70%+ | POOR | Errors increase. Stop, commit, `/compact` or `/clear`. |

**Planning rules:**
- Target completing the current plan within ~50% context usage
- Each plan should contain **2-3 tasks max** (not 10)
- If a plan has more than 3 tasks, split it into sequential plans
- When you feel context pressure, commit work and start a fresh session

## Discovery Levels

Not every task needs research. Match investigation depth to uncertainty.

| Level | Name | Time | When to Use | Example |
|---|---|---|---|---|
| 0 | Skip | 0 min | Internal work, existing patterns you know | Renaming a variable |
| 1 | Quick verify | 2-5 min | Confirm library syntax, check a type | "Does fetch() return a Response?" |
| 2 | Standard research | 15-30 min | Choosing between options, unfamiliar territory | "Redis vs Memcached for this use case" |
| 3 | Deep dive | 1+ hour | Architectural decisions, new technology evaluation | "Should we use event sourcing?" |

**Default to Level 1.** Only escalate when you hit genuine uncertainty.
Level 3 should be rare — if you're doing deep dives often, you're over-thinking.
