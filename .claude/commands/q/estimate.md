---
name: q:estimate
description: Forecast a build plan's token + dollar cost before running it
triggers: [estimate, forecast, cost, budget check, how expensive, pre-flight]
argument-hint: "[path to workflows/build-plan-*.md, or a feature name]"
allowed-tools: [Read, Glob, Grep, Bash, AskUserQuestion]
autonomy: confirm
namespace: planning
---

## Objective
Before running a build plan, forecast how many tokens and dollars it will cost on a
**no-cache budget**, flag the expensive parts, and offer a cheaper way to run it. This is
the pre-flight companion to `tools/token-burn.py` (which is the post-mortem).

## Why this matters (no-cache context)
With prompt caching off (Bedrock Sonnet 4.x), every token in context is re-sent and
re-billed at full input price **on every turn**. A file read on turn 1 of a long run is
paid for again on every later turn. Plans that front-load many reads quietly blow the
budget. This skill makes that visible before you spend it. See `context/budget-discipline.md`.

## Execution Context
- Read `context/budget-discipline.md` for the no-cache survival ruleset.
- Read `context/rules.md` for plan + atomic-commit conventions.
- The cost model lives in `tools/estimate-plan.py`; this skill drives it and interprets it.

## Process

1. **Resolve the plan.** Take the argument as a path to a `workflows/build-plan-*.md`
   (or a feature name). If none is given, Glob `workflows/build-plan-*.md` and ask the
   user which plan to estimate.

2. **Run the forecaster.**
   ```bash
   ./tools/estimate-plan.py <plan-path> --json
   ```
   Use `--json` for the structured numbers; optionally run it without `--json` to show the
   user the colored report. Pass `--turns-per-task N` if the plan's tasks are unusually
   large or small (default 6).

3. **Present the forecast.** Show:
   - expected **$ cost** and **token range** (low / expected / high)
   - the **top cost drivers** (which files, framework overhead, output)
   - whether expected cost exceeds the single-run cap
   - the tool's **recommendations** (partial reads, sub-agent isolation, plan split,
     `/compact` points)
   - the **ccusage ground-truth** line so the estimate is anchored to real spend.

4. **Offer a cheaper run.** If the forecast is heavy (over the cap, >3 tasks, or a single
   file dominates), propose a concrete cheaper plan — split into separate `/q:execute`
   sessions with `/clear` between, run via `/q:spinjitsu` (fresh worktrees), push big
   reads into sub-agents, or read large files partially.

5. **Ask how to proceed.** Use AskUserQuestion:
   - **Proceed as-is** — run the plan now (hand off to `/q:execute`).
   - **Optimize first** — apply the cheaper-run suggestions, then re-estimate.
   - **Split** — break the plan into smaller plans before running.

## Success Criteria
- Forecast (token range + $ + cost-driver table) presented for the given plan.
- Expensive drivers and a concrete cheaper-run option surfaced.
- User given a proceed / optimize / split decision.
- No files written by this skill itself — it only reads and forecasts.
