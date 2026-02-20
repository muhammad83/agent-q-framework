# Workflow: Code Review (Phase 2B — Review Planning)

## When to Use

Run this in **Plan Mode (Shift+Tab)** to review any existing code. Use it in two scenarios:

1. **After Phase 3 (build):** Review code Claude just built before deploying.
2. **Onboarding an existing project:** Review a pre-existing codebase to understand
   architecture, find issues, and plan improvements.

This is for reviewing existing code — not for greenfield planning (use the Reverse
Elicitation Prompt for that).


## How to Use

1. Start Claude Code: `claude`
2. Enter Plan Mode: `Shift+Tab`
3. Paste the prompt below
4. Choose BIG CHANGE or SMALL CHANGE when asked
5. Work through each section interactively
6. Once all sections are approved, exit Plan Mode: `Shift+Tab`
7. Let Claude execute the agreed changes


---


## The Prompt (Copy-Paste This)

Review this plan thoroughly before making any code changes. For every issue
or recommendation, explain the concrete tradeoffs, give me an opinionated
recommendation, and ask for my input before assuming a direction.

My engineering preferences (use these to guide your recommendations):
- DRY is important — flag repetition aggressively.
- Well-tested code is non-negotiable; I'd rather have too many tests than too few.
- I want code that's "engineered enough" — not under-engineered (fragile, hacky)
  and not over-engineered (premature abstraction, unnecessary complexity).
- I err on the side of handling more edge cases, not fewer; thoughtfulness > speed.
- Bias toward explicit over clever.

1. Architecture review
Evaluate:
- Overall system design and component boundaries.
- Dependency graph and coupling concerns.
- Data flow patterns and potential bottlenecks.
- Scaling characteristics and single points of failure.
- Security architecture (auth, data access, API boundaries).

2. Code quality review
Evaluate:
- Code organization and module structure.
- DRY violations — be aggressive here.
- Error handling patterns and missing edge cases (call these out explicitly).
- Technical debt hotspots.
- Areas that are over-engineered or under-engineered relative to my preferences.

3. Test review
Evaluate:
- Test coverage gaps (unit, integration, e2e).
- Test quality and assertion strength.
- Missing edge case coverage — be thorough.
- Untested failure modes and error paths.

4. Performance review
Evaluate:
- N+1 queries and database access patterns.
- Memory-usage concerns.
- Caching opportunities.
- Slow or high-complexity code paths.

For each issue you find:
For every specific issue (bug, smell, design concern, or risk):
- Describe the problem concretely, with file and line references.
- Present 2-3 options, including "do nothing" where that's reasonable.
- For each option, specify: implementation effort, risk, impact on other code,
  and maintenance burden.
- Give me your recommended option and why, mapped to my preferences above.
- Then explicitly ask whether I agree or want to choose a different direction
  before proceeding.

Workflow and interaction:
- Do not assume my priorities on timeline or scale.
- After each section, pause and ask for my feedback before moving on.

BEFORE YOU START:
Ask if I want one of two options:
1/ BIG CHANGE: Work through this interactively, one section at a time
   (Architecture → Code Quality → Tests → Performance) with at most 4 top
   issues in each section.
2/ SMALL CHANGE: Work through interactively ONE question per review section.

FOR EACH STAGE OF REVIEW: output the explanation and pros and cons of each
stage's questions AND your opinionated recommendation and why, and then use
AskUserQuestion. Also NUMBER issues and then give LETTERS for options and
when using AskUserQuestion make sure each option clearly labels the issue
NUMBER and option LETTER so the user doesn't get confused. Make the
recommended option always the 1st option.


---


## What Happens Next

After the review is complete and you've approved all changes:

1. Exit Plan Mode: `Shift+Tab`
2. Tell Claude: `Execute all the changes we agreed on in the review.`
3. Proceed to Phase 4 (Verification & Deployment)


---


## Where This Fits in the Agent Q Framework

Phase 1: Setup            ← file structure, CLAUDE.md, todo.md
Phase 2A: Build Plan      ← reverse elicitation (greenfield projects)
Phase 2B: Code Review     ← THIS WORKFLOW (post-build or existing project onboarding)
Phase 3: Build            ← auto-accept, execute plan
Phase 4: Verify & Deploy  ← chrome testing, Modal deploy


## Adding This to Your Starter Kit

cp code-review.md workflows/code-review.md
git add workflows/code-review.md
git commit -m "Add Phase 2B code review workflow"
git push

Then update your CHEATSHEET.md to reference Phase 2B alongside Phase 2A.