---
name: q:opus
description: Model-tiered run — strongest model to think, cheaper model to do
triggers: [opus, opus mode, model tier, tiered run, cheap execute, switch model]
argument-hint: "[path to an approved workflows/build-plan-*.md, or a feature name]"
allowed-tools: [Read, Glob, Grep, Bash, AskUserQuestion]
autonomy: confirm
namespace: execution
---

## Objective
Run an approved build plan through phases on **different models**: the strongest model
for thinking (plan, review, verify) and a cheaper model for doing (well-specified
execution). This cuts cost without cutting quality where it matters. The routing policy
lives in `context/model-tiers.md`; this skill sequences the phases and announces each
model switch.

## Config block (read tier → model IDs from here / `.env`)
Model IDs are **gateway-specific** — never hardcode a gateway's name in logic. Resolve, in
priority order: `.env` value → the default below. Read once at the start of the run.

```
Q_MODEL_THINK   # plan / review / verify / architecture   (default: gpt 5.2  | sonnet 4.6)
Q_MODEL_BUILD   # execute well-specified tasks             (default: sonnet 4.6 | gpt 4.1)
Q_MODEL_GRUNT   # mechanical: renames, boilerplate, docs   (default: gpt 4.1 mini | haiku)
```

Resolve them at start:
```bash
THINK="${Q_MODEL_THINK:-$(grep -E '^Q_MODEL_THINK=' .env 2>/dev/null | cut -d= -f2)}"; THINK="${THINK:-sonnet-4.6}"
BUILD="${Q_MODEL_BUILD:-$(grep -E '^Q_MODEL_BUILD=' .env 2>/dev/null | cut -d= -f2)}"; BUILD="${BUILD:-sonnet-4.6}"
GRUNT="${Q_MODEL_GRUNT:-$(grep -E '^Q_MODEL_GRUNT=' .env 2>/dev/null | cut -d= -f2)}"; GRUNT="${GRUNT:-haiku}"
```

## Why the explicit switches
The main-loop model is **user-controlled** — this skill cannot silently change it. So at
each phase boundary it prints a switch instruction and waits for the user to confirm the
switch before proceeding:

```
→ switch to THINK ({Q_MODEL_THINK}): /model {id}
```

## Execution Context
- Read `context/model-tiers.md` for the tier policy and the task-type → tier table.
- Read `context/rules.md` for deviation rules + atomic commits.
- Read `context/budget-discipline.md` for why this matters on a no-cache budget.

## Process

1. **Resolve the plan + config.** Take the argument as a path to an approved
   `workflows/build-plan-*.md` (or feature name). Read the tier→model IDs from the config
   block / `.env`. If no plan is given, Glob and ask which to run.

2. **THINK phase — plan & review.**
   - Emit: `→ switch to THINK ({THINK}): /model {id}` and wait for confirmation.
   - Ensure the plan exists and is sound. If it has not been review-gated, run the plan
     review (see `workflows/review-eng.md`). Surface the verdict.

3. **BUILD phase — execute.**
   - Emit: `→ switch to BUILD ({BUILD}): /model {id}` and wait for confirmation.
   - Hand the plan's tasks to execution (delegate to `/q:execute`, or to sub-agents for
     isolatable work). For mechanical task chunks, note they may run on GRUNT ({GRUNT}).
   - Follow deviation rules; commit atomically per task.

4. **VERIFY phase — back to THINK.**
   - Emit: `→ switch to THINK ({THINK}): /model {id}` and wait for confirmation.
   - Run verification / review against the plan before the run is considered done
     (`/q:verify`). Do not verify on the cheap model.

5. **Report.** Summarize what ran on which tier and the phases completed.

## Success Criteria
- Each phase boundary emitted an explicit `/model` switch instruction in THINK → BUILD →
  THINK order, and proceeded only after the switch was confirmed.
- Model IDs came from config / `.env`, never hardcoded.
- Plan executed with atomic commits; verification ran on the THINK tier.

## Edge cases
- **Unknown gateway IDs:** ship the defaults above; the run still works, IDs just need
  filling in `.env`. Never block on a missing ID — fall back to the default and note it.
- **User stays on one model:** if the user declines to switch, continue on the current
  model but warn that the cost/quality trade-off of opus mode is lost.
