# Build Plan — Token Economy Tooling (no-cache Bedrock Sonnet 4.6)

**Created:** 2026-06-04
**Discovery level:** 1 (patterns known; only gateway model IDs uncertain → made config-driven)
**Context:** $40/day (~16M tokens) budget, 08:00–20:00 workday, **no prompt caching** →
every tool result is re-billed at full input price on every subsequent turn.

---

## Background: why no-cache changes everything

Prompt caching normally stores the unchanging prefix of a conversation (system prompt,
framework rules, already-read files) and bills its reuse at ~10% of full price. Without it,
**every token in context is re-sent and re-billed at full price on every turn.** Per
`tools/token-burn.py`'s own model: a 5k-token file read on turn 1 of a 40-turn session
costs ~5k × 40 = 200k cumulative input tokens. With cache that's ~$0.06; without, ~$0.60.

Implications this plan is built around:
1. **Context length is the cost driver**, not just output volume.
2. Fat team plans that front-load many file reads tax every later turn → they "blow up."
3. Highest-leverage moves: keep context small, `/compact` often, push file reads into
   sub-agents that return summaries (the file content dies with the sub-agent).

Pricing assumption (Bedrock Sonnet 4.x, configurable): **input $3/M, output $15/M.**

---

## Task 1 — Workday budget guard ("survive 8→20")

**Goal:** Never run out of budget mid-day. Show live pace; warn before overspend.

**Create:**
- `tools/budget-guard.sh` — reads ccusage daily cumulative cost, compares against
  `Q_DAILY_BUDGET_USD` (default 40) and **time-of-day linear pacing** between
  `Q_WORKDAY_START` (8) and `Q_WORKDAY_END` (20). Emits:
  - spent today, budget remaining, % of budget used
  - **pace status**: `AHEAD` / `ON-TRACK` / `BEHIND` (behind pace = good = green;
    over pace = orange/red), computed as `spent_fraction` vs `time_fraction`
  - projected end-of-day spend at current burn rate
  - `--json` mode for statusline consumption; plain mode for manual `./tools/budget-guard.sh`
  - Degrades silently if ccusage/jq absent (mirrors `commit-cost.sh`).
- `context/budget-discipline.md` — the no-cache survival ruleset:
  - Sustainable rate math (~$3.33/hr, ~1.33M tok/hr)
  - When to `/compact` vs `/clear` vs start fresh session (cost-justified, not just tidy)
  - "Read less, summarize via sub-agent" pattern with a concrete example
  - How to check whether caching can be enabled on Bedrock (request to infra)

**Modify:**
- `tools/statusline-hud.sh` — add a budget/pace segment (spent · remaining · pace bar)
  reusing the existing `build_bar` + `color_for_pct` helpers and palette.
- `.env.example` — document `Q_DAILY_BUDGET_USD`, `Q_WORKDAY_START`, `Q_WORKDAY_END`,
  `Q_INPUT_PRICE_PER_M`, `Q_OUTPUT_PRICE_PER_M`.

**Verify:** run `./tools/budget-guard.sh` (plain + `--json`); confirm statusline renders
with and without ccusage present.

**Commit:** `feat(tools): add workday budget guard + pace-aware statusline segment`

---

## Task 2 — `/q:estimate` — pre-flight plan cost forecaster

**Goal:** Before running a team build-plan, forecast tokens + $ and flag what's expensive.

**Create:**
- `tools/estimate-plan.py` — given a `build-plan-*.md` path:
  - Parse the plan's **Create/Modify/Delete file list** and any referenced paths.
  - Measure real sizes (chars/4) of files that will be **read** (modify/reference targets).
  - Estimate **turn count** from task count (configurable turns-per-task, default ~6).
  - Model **no-cache cumulative exposure**: each read's tokens × remaining turns +
    per-turn framework/system overhead (default ~12k) + estimated output per turn.
    Mirror `token-burn.py`'s "size × remaining-turns" weighting so the two agree.
  - Output: **low / expected / high** token range, **$ cost** at configured prices,
    and a ranked **top cost drivers** table (which files, framework overhead, output).
  - Recommendations engine: flag files to read partially (offset/limit), where a
    sub-agent would isolate a big read, whether to split the plan (>3 tasks or
    projected > a configurable single-run cap), and `/compact` points.
  - Print **ground-truth ccusage** scale note so estimates can be calibrated.
  - `--json` for skill consumption.
- `.claude/commands/q/estimate.md` — skill that: loads the plan, runs `estimate-plan.py`,
  presents the forecast + cheaper-run plan, and asks whether to proceed / optimize / split.
  Frontmatter matches existing q skills (name `q:estimate`, namespace `planning`,
  `allowed-tools: [Read, Glob, Grep, Bash, AskUserQuestion]`, autonomy `confirm`).

**Modify:**
- `.claude/commands/q/status.md` + `SKILL.md` — register `/q:estimate`.
- `README.md` — add to file map (tools + commands).

**Verify:** run `estimate-plan.py` against a real `workflows/build-plan-gstack-*.md`;
sanity-check the range against `token-burn.py` on a comparable past session.

**Commit:** `feat(skill): add /q:estimate plan cost forecaster + estimate-plan.py`

---

## Task 3 — `/q:opus` — model-tiered run (best for thinking, cheap for doing)

**Goal:** Use the strongest model for planning/review/verification and a cheaper model
for execution, via the single gateway. Cut cost without cutting quality where it matters.

**Models available:** sonnet 4.6, gpt 5.2, haiku, gpt 4.1, gpt 4.1 mini.

**Create:**
- `context/model-tiers.md` — the routing policy (config-driven IDs, not hardcoded):
  - **THINK tier** (plan, review, verify, architectural decisions): strongest —
    gpt 5.2 / sonnet 4.6.
  - **BUILD tier** (execute well-specified tasks): sonnet 4.6 (default) or gpt 4.1 for bulk.
  - **GRUNT tier** (mechanical: renames, formatting, boilerplate, doc sync): gpt 4.1 mini / haiku.
  - Decision table: task type → tier → model, with a "when to downshift/upshift" guide
    and the cost rationale (cheap model on cheap work is the single biggest lever after caching).
- `.claude/commands/q/opus.md` — phased orchestration skill ("opus mode"):
  1. THINK phase: ensure top model, run/҂load the plan + review gate.
  2. At each phase boundary, **emit an explicit model-switch instruction**
     (`→ switch to {model}: /model {id}`) since the main loop's model is user-controlled,
     then proceed once switched.
  3. BUILD phase: hand tasks to the BUILD-tier model (delegate via execute / sub-agents).
  4. VERIFY phase: switch back to THINK tier for review/verification before commit.
  - Frontmatter matches q skills (name `q:opus`, namespace `orchestration`, autonomy `confirm`).
  - Model IDs read from a config block at top of the skill + `.env` (gateway-specific),
    so swapping gateway model names never touches logic.

**Modify:**
- `.claude/commands/q/status.md` + `SKILL.md` — register `/q:opus`.
- `.env.example` — document tier→model-ID env vars
  (`Q_MODEL_THINK`, `Q_MODEL_BUILD`, `Q_MODEL_GRUNT`).
- `README.md` — add to command map.

**Verify:** dry-run the skill on a small plan; confirm phase gates + switch prompts fire
in order and IDs come from config.

**Commit:** `feat(skill): add /q:opus model-tiered run + model-tiers policy`

---

## Edge cases & rollback

- **ccusage absent:** all cost tools degrade silently (existing pattern) → no crash.
- **No file list in plan:** estimator falls back to task-count heuristic + prints a
  low-confidence warning.
- **Unknown gateway model IDs:** everything reads IDs from `.env`/config block; ship
  sensible defaults but never hardcode in logic.
- **Caching status unknown:** `budget-discipline.md` includes the "how to check / request
  Bedrock prompt caching" steps, since enabling it would 5–10× the effective budget.
- **Rollback:** fully additive. Undo = delete new files + revert statusline/README/
  status.md/.env.example edits. One atomic commit per task → revert individually.

## Execution strategy (practice what we preach)

These 3 tasks are **independent and additive** — no shared state. On a no-cache budget,
running all three in one long session would front-load every read and re-bill it each
turn. So:
- Run **each task as its own `/q:execute` session**, with `/clear` between them.
- Or run them in parallel via `/q:spinjitsu` (separate worktrees, fresh context each).
- Build **Task 1 first** (budget guard) so the pacer is live while building Tasks 2–3.

## Verification criteria
- [ ] `budget-guard.sh` runs in plain + `--json`, statusline renders, degrades w/o ccusage
- [ ] `estimate-plan.py` produces a token range + $ + cost-driver table on a real plan
- [ ] `/q:estimate` and `/q:opus` registered in status.md + SKILL.md + README
- [ ] `model-tiers.md` + `budget-discipline.md` pass `./tools/verify.sh`
- [ ] All three tasks committed atomically; `.env.example` documents all new vars
- [ ] todo.md updated
