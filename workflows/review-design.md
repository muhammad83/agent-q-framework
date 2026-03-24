---
name: review-design
description: >
  Designer's eye plan review. Rates each design dimension 0-10, explains what
  would make it a 10, then improves the plan to get there. Seven passes:
  information architecture, interaction states, user journey, AI slop risk,
  design system alignment, responsive/a11y, and unresolved decisions.
autonomy: interactive
namespace: review
triggers:
  - user asks for "design review", "design critique", "review the design plan"
  - plan has UI/UX components that should be reviewed before implementation
---

# Workflow: Design Plan Review

## Trigger
Run this when a plan has UI/UX components and the user wants a design review
before implementation. For live-site visual audits of already-built UI, this
workflow is not appropriate — use a code-level design review instead.

## Context Needed
Before running, make sure you have:
- [ ] The plan file to review
- [ ] `todo.md` for current project state
- [ ] `agents/q-reviewer.md` for report format and severity levels
- [ ] DESIGN.md or design-system docs if they exist in the project

## Pre-Review: UI Scope Detection
Analyze the plan. If it involves NONE of: new UI screens, changes to existing UI,
user-facing interactions, frontend framework changes, or design system changes —
tell the user: "This plan has no UI scope. A design review is not applicable."
and exit early. Do not force design review on a backend change.

## Design Principles
1. Empty states are features — warmth, a primary action, and context.
2. Every screen has a hierarchy — first, second, third. If everything competes, nothing wins.
3. Specificity over vibes — "clean modern UI" is not a design decision.
4. Edge cases are user experiences — 47-char names, zero results, error states.
5. Responsive is not "stacked on mobile" — each viewport gets intentional design.
6. Accessibility is not optional — keyboard nav, screen readers, contrast, touch targets.
7. Subtraction default — if a UI element does not earn its pixels, cut it.
8. Trust is earned at the pixel level.

## The 0-10 Rating Method
For each design pass, rate the plan 0-10 on that dimension. If not a 10:
1. Rate: "Information Architecture: 4/10"
2. Gap: explain what a 10 would look like
3. Fix: add the missing specification to the plan
4. Re-rate: "Now 8/10 — still missing mobile nav hierarchy"
5. Ask the user if there is a genuine design choice to resolve

## Steps

### Step 0: Design Scope Assessment

**0A. Initial Rating** — Rate the plan's overall design completeness 0-10.
Explain what a 10 looks like for THIS plan.

**0B. Design System Status** — Check if DESIGN.md exists. If yes, calibrate all
decisions against it. If no, note the gap and proceed with universal principles.

**0C. Existing Design Leverage** — What existing UI patterns, components, or
design decisions in the codebase should this plan reuse?

**0D. Focus Areas** — Ask the user: "I have rated this plan {N}/10 on design
completeness. The biggest gaps are {X, Y, Z}. Want me to review all 7 passes,
or focus on specific areas?"

### Pass 1: Information Architecture
Rate 0-10: Does the plan define what the user sees first, second, third?

Fix to 10: Add information hierarchy to the plan. Include ASCII diagram of
screen/page structure and navigation flow. Apply constraint thinking — if you
can only show 3 things, which 3?

### Pass 2: Interaction State Coverage
Rate 0-10: Does the plan specify loading, empty, error, success, partial states?

Fix to 10: Add interaction state table:
```
FEATURE              | LOADING | EMPTY | ERROR | SUCCESS | PARTIAL
---------------------|---------|-------|-------|---------|--------
[each UI feature]    | [spec]  | [spec]| [spec]| [spec]  | [spec]
```
For each state: describe what the user SEES, not backend behavior.
Empty states are features — specify warmth, primary action, context.

### Pass 3: User Journey and Emotional Arc
Rate 0-10: Does the plan consider the user's emotional experience?

Fix to 10: Add user journey storyboard:
```
STEP | USER DOES        | USER FEELS      | PLAN SPECIFIES?
-----|------------------|-----------------|----------------
1    | Lands on page    | [what emotion?] | [what supports it?]
...
```
Apply time-horizon design: 5-second visceral, 5-minute behavioral, 5-year reflective.

### Pass 4: AI Slop Risk
Rate 0-10: Does the plan describe specific, intentional UI — or generic patterns?

Rewrite vague UI descriptions with specific alternatives. Watch for:
- Generic card grids as first impression
- "Clean, modern UI" with no actual design decisions
- Hero sections that feel like every other AI-generated site
- 3-column icon-title-description feature grids
- Purple/violet gradient backgrounds
- Centered everything with no visual hierarchy
- Emoji as design elements
- Cookie-cutter section rhythm

### Pass 5: Design System Alignment
Rate 0-10: Does the plan align with DESIGN.md (if it exists)?

If DESIGN.md exists: annotate with specific tokens/components.
If no DESIGN.md: flag the gap and recommend creating one.
Flag any new component — does it fit the existing vocabulary?

### Pass 6: Responsive and Accessibility
Rate 0-10: Does the plan specify mobile/tablet, keyboard nav, screen readers?

Fix to 10:
- Responsive specs per viewport — intentional layout changes, not just stacking.
- WCAG 2.1 basics: keyboard navigation patterns, ARIA landmarks, touch target
  sizes (44px minimum), color contrast requirements.

### Pass 7: Unresolved Design Decisions
Surface ambiguities that will haunt implementation:
```
DECISION NEEDED              | IF DEFERRED, WHAT HAPPENS
-----------------------------|---------------------------
What does empty state look like? | Engineer ships "No items found."
Mobile nav pattern?          | Desktop nav hides behind hamburger
...
```
Each decision: ask the user with recommendation, rationale, and alternatives.
Edit the plan with each decision as it is made.

### Required Outputs
1. **"NOT in scope" section** — design decisions deferred, with rationale.
2. **"What already exists" section** — existing patterns and components to reuse.
3. **todo.md updates** — for design debt: missing a11y, unresolved responsive
   behavior, deferred empty states. Present each TODO individually.
4. **Completion summary:**
   ```
   DESIGN REVIEW — COMPLETION SUMMARY
   ==========================================
   Pass 1 (Info Arch):   __/10 -> __/10
   Pass 2 (States):      __/10 -> __/10
   Pass 3 (Journey):     __/10 -> __/10
   Pass 4 (AI Slop):     __/10 -> __/10
   Pass 5 (Design Sys):  __/10 -> __/10
   Pass 6 (Responsive):  __/10 -> __/10
   Pass 7 (Decisions):   __ resolved, __ deferred
   Overall:              __/10 -> __/10
   ```

## Tools Used
- File reading tools for plan inspection and DESIGN.md
- Search tools for existing UI patterns in the codebase

## Output
- Structured review report with per-pass ratings
- Updated plan file with design specifications added
- Updated `todo.md` with design debt items

## Success Criteria
- All 7 passes evaluated and rated
- Interaction state table produced for each UI feature
- No pass below 8/10 without explicit user acknowledgment
- "NOT in scope" and "What already exists" sections written
- Every deferred design decision documented

## Edge Cases
- Plan has no UI scope: exit early, do not force a design review.
- No DESIGN.md exists: proceed with universal principles, flag the gap.
- User wants to skip passes: allow it, note which were skipped.
- Context pressure: prioritize Pass 2 (Interaction States) > Pass 4 (AI Slop) >
  Pass 1 (Information Architecture) > Pass 3 (Journey) > everything else.
