# Agent Q — Model Tiers (cost-tiered routing)

Routing policy for running through a **single gateway** with multiple models: use the
strongest model where thinking quality pays for itself (planning, review, verification)
and a cheaper model for well-specified, test-guarded execution. After enabling caching,
**putting the cheap model on cheap work is the single biggest cost lever** — and caching
is off here permanently (see `context/budget-discipline.md`), so it's the biggest lever, full stop.

Load this when deciding which model to run a phase on, or when driving `/q:opus`.

Model IDs are **gateway-specific and config-driven** — set them in `.env`; never hardcode
a gateway's model name in skill logic. Defaults below are the ones this setup ships with.

## Models available (this gateway)
`sonnet 4.6` · `gpt 5.2` · `gpt 4.1` · `gpt 4.1 mini` · `haiku`

## The three tiers

| Tier | Use for | Model (env var) | Default |
|------|---------|-----------------|---------|
| **THINK** | planning, reviews, verification, architectural decisions, debugging novel logic | `Q_MODEL_THINK` | `gpt 5.2` (or `sonnet 4.6`) |
| **BUILD** | executing well-specified tasks from an approved plan | `Q_MODEL_BUILD` | `sonnet 4.6` (or `gpt 4.1` for bulk) |
| **GRUNT** | mechanical work: renames, formatting, boilerplate, doc sync | `Q_MODEL_GRUNT` | `gpt 4.1 mini` (or `haiku`) |

## Decision table: task type → tier

| Task type | Tier | Why |
|-----------|------|-----|
| Reverse-elicitation planning (`/q:plan`) | THINK | A wrong plan is the most expensive error; pay for the best reasoning up front. |
| Plan / code / PR review (`/q:review`, review gates) | THINK | Reviews catch costly defects; weak reviewers miss them. |
| Verification against spec (`/q:verify`) | THINK | The last gate before commit — don't economize here. |
| Debugging novel/unclear failures (`/q:debug`) | THINK | Hypothesis quality dominates; cheap models flail and burn more. |
| Executing an approved, well-specified task (`/q:execute`) | BUILD | Spec + tests constrain the work; mid-tier is reliable and cheaper. |
| Bulk edits across many similar files | BUILD→GRUNT | If each edit is mechanical and verifiable, downshift to GRUNT. |
| Renames, import fixes, formatting, lint cleanup | GRUNT | Deterministic, test/compiler-checked — cheapest model is fine. |
| Doc sync, changelog, comment updates (`/q:docs`) | GRUNT | Low-risk prose tracking known changes. |

## When to downshift (THINK/BUILD → cheaper)
- The task is **fully specified** and **guarded by tests or a compiler** — rework is cheap to catch.
- The change is **mechanical and repetitive** (same edit, many sites).
- You're **over pace** (`budget-guard.sh` shows `over pace` / `OVER BUDGET RISK`).

## When to upshift (→ THINK)
- The result is **hard to verify** or **expensive if wrong** (architecture, security, data model).
- The cheaper model **stalled, looped, or produced rework** — escalate rather than retry blindly.
- You're making a **decision the rest of the plan depends on**.

## Cost rationale
Rework is the hidden cost: a cheap model on novel logic that needs three correction rounds
costs more than the strong model once. So the rule is **cheap model only on cheap, verifiable
work**; never cheap-model novel reasoning. With no caching, a stalled cheap model is doubly
bad — every retry re-bills the whole context. The savings come from *volume of mechanical work*
moved to GRUNT, not from shaving the few high-stakes THINK turns.

## How `/q:opus` uses this
`/q:opus` reads these tier→model bindings from `.env` and drives a plan through phases:
THINK (plan + review) → BUILD (execute) → THINK (verify), emitting an explicit
`→ switch to {model}: /model {id}` at each boundary because the main-loop model is
user-controlled. The policy lives here; the skill only sequences and announces switches.

## Next Steps

- [ ] Fill in your gateway's real model IDs for `Q_MODEL_THINK` / `Q_MODEL_BUILD` /
      `Q_MODEL_GRUNT` in `.env` (defaults are placeholders) before 2026-06-30.
- [ ] Run `/q:opus` on a small approved plan to confirm the phase switches fire in order.
- [ ] Revisit tier assignments after a week of real use — move more work to GRUNT if quality holds.
