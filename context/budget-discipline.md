# Agent Q — Budget Discipline (no-cache Bedrock)

Survival rules for working an 08:00–20:00 day on a fixed daily AI budget when
**prompt caching is disabled**. Load this when cost matters or `budget-guard.sh`
shows `over pace` / `OVER BUDGET RISK`.

Defaults assumed (override in `.env`): **$40/day, 08:00–20:00, $3/M in, $15/M out.**

---

## Why no-cache is the whole problem

With prompt caching, the unchanging prefix of a conversation (system prompt,
framework rules, files already read) is billed at ~10% of full price on reuse.
**Without it, every token in context is re-sent and re-billed at full price on
every turn.** A 5k-token file read on turn 1 of a 40-turn session costs ~5k × 40
= 200k cumulative input tokens — ~$0.06 with cache, ~$0.60 without (10×).

Consequences:
- **Context length is the cost driver**, not just output volume.
- Long sessions are punished super-linearly.
- Plans that front-load many file reads tax every later turn — this is why team
  plans "blow up."

## The sustainable rate

$40 over a 12-hour day ≈ **$3.33/hr ≈ 1.1M tokens/hr** (blended). `budget-guard.sh`
compares spend-so-far against time-of-day so you see pace, not just total. The
statusline shows it live: `budget … under/on/over pace · ~$X eod`.

## Rules (in priority order)

1. **Keep context small.** This is lever #1 — bigger than model choice. Read only
   what you need; use `Read` with `offset`/`limit`; prefer `Grep` over full reads.
2. **`/compact` is worth money, not just tidiness.** At 50% context, compact after
   committing. At 70%+, compact or `/clear` immediately. Each compaction stops the
   re-billing of stale tool results on every future turn.
3. **Start fresh sessions between independent tasks.** A `/clear` (or new session)
   drops the entire re-billed history. Cheaper than carrying it.
4. **Push big reads into sub-agents.** A sub-agent reads the file and returns a
   summary; the file's tokens die with the sub-agent instead of taxing your main
   thread for the rest of the session.
5. **Estimate before running team plans.** Use `/q:estimate` to forecast a plan's
   tokens + $ and flag expensive reads before they hit your budget.
6. **Tier models where quality holds.** Strong model for plan/review/verify; cheap
   model for mechanical, test-guarded execution only (see `context/model-tiers.md`,
   `/q:opus`). Never cheap-model novel logic — rework costs more than it saves.
7. **Commit atomically.** Frequent commits let you `/clear` without losing work.
8. **Batch tool calls.** Parallel reads in one turn beat sequential turns (each
   turn re-bills the whole context).

## When `budget-guard.sh` flags `over pace`

- Commit current work, then `/compact` or `/clear`.
- Switch to a cheaper model for any remaining mechanical work.
- Defer non-essential reads/refactors to a fresh session tomorrow.
- Re-check pace with `./tools/budget-guard.sh`.

## Next Steps

- [ ] **Confirm whether Bedrock prompt caching can be enabled** (see below) by
      2026-06-11 — it would 5–10× the effective budget and make most of the above
      far less painful.
- [ ] Set real values in `.env` if your budget/workday/prices differ from defaults.
- [ ] Run `./tools/budget-guard.sh` at the start of each workday to set a baseline.

### How to check / request prompt caching on Bedrock

1. Caching support depends on the model + region + how the gateway calls Bedrock
   (the request must send `cache_control` breakpoints on the system/prompt blocks).
2. Ask infra: "Does our Bedrock gateway pass Anthropic `cache_control` breakpoints,
   and is prompt caching enabled for Sonnet 4.6 in our region?"
3. If the gateway strips or omits `cache_control`, no caching happens regardless of
   model support — that's a gateway config change to request.
4. If it can be enabled, re-run a representative session and compare `ccusage` daily
   cost before/after to confirm the discount is landing.
