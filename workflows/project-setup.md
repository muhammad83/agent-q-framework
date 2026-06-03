# Workflow: Project Setup Interview

## Trigger
Run this when a user starts a new project using the Agent Q framework.
Replaces the free-form "describe your project in 2-3 sentences" step
with a structured interview that profiles the project, recommends
which framework features to adopt, and lets the user choose.

## Context Needed
Before running, make sure you have:
- [ ] Agent Q framework repo is available at `~/Documents/Projects/agent-q-framework/`
- [ ] User is ready to answer 5 questions about their project (~2-3 minutes)

## IMPORTANT: Symlink, Never Copy
Framework files (`agents/`, `context/`, `workflows/`, `tools/`, `shared_context/`, `soul.md`, `SKILL.md`, `CHEATSHEET.md`, `CONTRIBUTING.md`) must be **symlinked** from the canonical `agent-q-framework/` repo, never copied. This prevents 300K+ of duplicated bloat per project. See Stage 4B for details.

## Overview

4 stages:
1. **Profile** — 5 questions to understand the project
2. **Recommend** — Present feature menu with per-item recommendations
3. **Select** — User picks/modifies recommendations
4. **Generate** — Create customized project files

---

## Stage 1: Project Profile Interview

Ask these 5 questions in order. For each question, present the options
and state your recommended answer based on what you know so far.
If the user says "you decide" or "not sure", go with your recommendation
and move on.

### Q1: What are you building?
Give me a 1-2 sentence description, then pick the closest type:
- **A) Marketing site / landing page** — Static content, SEO, conversion
- **B) Web application** — Dynamic features, user accounts, database
- **C) API / backend service** — Endpoints, data processing, integrations
- **D) CLI tool / script** — Command-line utility, automation
- **E) AI agent / bot** — LLM-powered tool, chatbot, automation agent
- **F) Mobile app** — iOS, Android, or cross-platform
- **G) Data pipeline** — ETL, analytics, data processing
- **H) Other** — Describe it

*Determines: frontend rules, engineering complexity, which workflows apply.*

### Q2: What is your tech stack?
Pick all that apply or describe your own:
- **Languages:** Python / TypeScript / JavaScript / Go / Rust / Other
- **Frontend:** None (static HTML) / React / Next.js / Astro / Vue / Svelte / No frontend
- **Backend:** None / FastAPI / Express / Django / Rails / Other / No backend
- **Database:** None / PostgreSQL / SQLite / MongoDB / Supabase / Other
- **Deployment:** Local only / Vercel / Railway / Modal / AWS / Docker / Other

*Determines: engineering preferences, verification checks, deployment config.*

### Q3: What is the project scale and stage?
- **A) Solo hobby / experiment** — Just you, learning or prototyping, no users yet
- **B) Solo serious** — Just you, but shipping to real users
- **C) Small team (2-5)** — Collaborating, need coordination
- **D) Team (5+)** — Multiple contributors, need structure and process
- **E) Existing codebase onboarding** — Project already exists, adding Agent Q

*Determines: overhead tolerance — whether parallel execution, code review, docs rules are worth it.*

### Q4: What is the urgency and quality bar?
- **A) Ship fast, fix later** — Prototype or MVP, speed over polish
- **B) Balanced** — Good quality but don't over-engineer, ship in days not weeks
- **C) High quality** — Production code, thorough testing, edge cases matter
- **D) Mission-critical** — Cannot break, security audit, rollback plans, full test coverage

*Determines: planning depth, testing requirements, verification strictness.*

### Q5: Which AI tools will you use?
- **A) Claude Code only**
- **B) Claude Code + OpenAI Codex**
- **C) Claude Code + GitHub Copilot**
- **D) Claude Code + Google Antigravity**
- **E) Multiple / all of the above**
- **F) Not sure yet — just set up Claude Code for now**

*Determines: which config files to generate.*

---

## Stage 2: Feature Menu

After the interview, compute a recommendation for each feature using the
logic below, then present the full table to the user.

### Recommendation Legend
- **INCLUDE** — Recommended for your project. Included unless you opt out.
- **OPTIONAL** — Available but not critical. Your call.
- **SKIP** — Adds overhead without clear benefit. Excluded unless you opt in.

### Feature Inventory

Present this table with the Rec column filled in:

```
========================================
  AGENT Q — FEATURE MENU
  Project: [name from Q1]
  Profile: [type] / [stack] / [scale] / [quality bar]
========================================

#   Feature                          Rec       What It Does
--- -------------------------------- --------- -------------------------------------------
    CORE
1   Core rules (todo.md, 2-strike)   INCLUDE   State tracking, self-improvement, ask-don't-guess
2   Pass-by-reference architecture   [rec]     Thin CLAUDE.md pointing to context/ files
3   Planning protocol (8-question)   [rec]     Structured interview before multi-file changes
4   Engineering preferences          [rec]     DRY, testing, edge cases, explicit > clever

    DOMAIN RULES
5   Frontend rules                   [rec]     Visual verification, mobile-first, brand assets
6   Documentation auto-update        [rec]     Auto-update docs when APIs/structure change

    WORKFLOWS
7   Code review (Phase 2B)           [rec]     4-section review: architecture, code, tests, perf
8   Spin Jit Su parallel execution   [rec]     Run multiple AI instances in parallel via tmux
9   Post-build refactor              [rec]     4 retrospective questions after every feature

    TOOLS
10  Verification script (verify.sh)  [rec]     Boolean pass/fail checks on output files
11  Heartbeat monitoring             [rec]     Proactive project health checks

    IDENTITY
12  Soul.md (agent personality)      [rec]     Agent writes its own personality and tone

    TOOL CONFIGS
13  CLAUDE.md (Claude Code)          INCLUDE   Always generated
14  agent.md (OpenAI Codex)          [rec]     Config for Codex
15  copilot-instructions.md          [rec]     Config for GitHub Copilot
16  .agent/rules/agent-q.md          [rec]     Config for Google Antigravity

    CONTEXT AWARENESS
17  Context monitor hooks            [rec]     Status bar + warnings when context runs low
18  Slash commands (/q:*)            [rec]     9 commands replacing copy-paste prompts

    SESSION MANAGEMENT
19  Pause/Resume workflows           [rec]     Save & restore session state across context clears
20  Debug workflow                   [rec]     Scientific method debugging with investigation tracking

    AGENTS
21  Subagent roles (agents/)         [rec]     Planner, executor, verifier, debugger role definitions
22  Subagent spawning                [rec]     Spawn parallel executors via Task tool

    TOKEN & MCP HYGIENE
23  Token-burn analyzer              [rec]     Rank what burned tokens in a session (by tool/file/cache re-reads)
24  MCP hygiene audit (SessionStart) [rec]     Warn at session start about connected-but-unused MCP servers

Legend: INCLUDE = recommended | OPTIONAL = your call | SKIP = not needed
```

After the table, show each SKIP and OPTIONAL item with a one-line rationale:
```
Why some features are SKIP/OPTIONAL for your project:
- #8 Spin Jit Su: SKIP — solo project, one thing at a time
- #11 Heartbeat: SKIP — not a production backend service
- #12 Soul.md: OPTIONAL — useful for long projects, skip for quick ones
```

Then ask:
```
Type changes as comma-separated list, e.g.: "3 include, 8 skip, 12 include"
Or "looks good" to accept all recommendations.
```

### Recommendation Logic

Use these rules to fill the Rec column:

**#1 Core rules** → INCLUDE always.

**#2 Pass-by-reference architecture**
- Solo hobby (Q3=A) + ship fast (Q4=A) → SKIP (inline everything for simplicity)
- All other combos → INCLUDE

**#3 Planning protocol (8-question)**
- Ship fast (Q4=A) → SKIP (use simplified 4-question inline version)
- Balanced (Q4=B) → OPTIONAL (offer full or simplified)
- High quality or mission-critical (Q4=C/D) → INCLUDE
- Team 5+ (Q3=D) → INCLUDE regardless of quality bar

**#4 Engineering preferences**
- Ship fast (Q4=A) → SKIP
- All others → INCLUDE

**#5 Frontend rules**
- Project has frontend (Q1=A/B/F, or Q2 has a frontend framework) → INCLUDE
- No frontend (Q1=C/D/E/G with no frontend in Q2) → SKIP

**#6 Documentation auto-update**
- Ship fast (Q4=A) → SKIP
- API/CLI/high-quality (Q1=C/D, Q4=C/D) → INCLUDE
- All others → OPTIONAL

**#7 Code review (Phase 2B)**
- Ship fast (Q4=A) → SKIP
- Existing codebase (Q3=E) → INCLUDE always
- High quality/mission-critical or team (Q4=C/D or Q3=C/D) → INCLUDE
- Balanced + solo (Q4=B + Q3=A/B) → OPTIONAL

**#8 Spin Jit Su parallel execution**
- Solo hobby (Q3=A) → SKIP
- Solo serious (Q3=B) with one project at a time → OPTIONAL
- Small team or team (Q3=C/D) → INCLUDE
- Ship fast (Q4=A) → OPTIONAL regardless of scale

**#9 Post-build refactor**
- Ship fast (Q4=A) → SKIP
- Balanced (Q4=B) → OPTIONAL
- High quality/mission-critical (Q4=C/D) → INCLUDE

**#10 Verification script**
- Ship fast (Q4=A) → SKIP
- AI agent (Q1=E) → INCLUDE
- Mission-critical (Q4=D) → INCLUDE
- All others → OPTIONAL

**#11 Heartbeat monitoring**
- Ship fast or balanced (Q4=A/B) → SKIP
- Mission-critical (Q4=D) or production AI agent (Q1=E) → INCLUDE
- High quality with deployment (Q4=C) → OPTIONAL

**#12 Soul.md**
- Team (Q3=C/D) → INCLUDE (consistency across sessions)
- All others → OPTIONAL

**#13 CLAUDE.md** → INCLUDE always.

**#14-16 Tool configs** — based on Q5:
- Q5=A → SKIP #14, #15, #16
- Q5=B → INCLUDE #14, SKIP #15, #16
- Q5=C → SKIP #14, INCLUDE #15, SKIP #16
- Q5=D → SKIP #14, #15, INCLUDE #16
- Q5=E → INCLUDE all
- Q5=F → SKIP all (note they exist if needed later)

**#17 Context monitor hooks**
- Q5 includes Claude Code (A/B/C/D/E) → INCLUDE
- Q5=F → OPTIONAL (hooks are Claude Code specific, but useful for any future setup)

**#18 Slash commands (/q:*)**
- Q5 includes Claude Code (A/B/C/D/E) → INCLUDE
- Q5=F → SKIP (slash commands are Claude Code specific)

**#19 Pause/Resume workflows**
- Balanced or higher (Q4=B/C/D) → INCLUDE (session continuity matters)
- Ship fast (Q4=A) → OPTIONAL

**#20 Debug workflow**
- High quality or mission-critical (Q4=C/D) → INCLUDE
- Balanced (Q4=B) → OPTIONAL
- Ship fast (Q4=A) → SKIP

**#21 Subagent roles (agents/)**
- Team (Q3=C/D) → INCLUDE (role clarity across sessions)
- Solo serious (Q3=B) → OPTIONAL
- Solo hobby (Q3=A) + ship fast (Q4=A) → SKIP

**#22 Subagent spawning**
- Same as #8 (Spin Jit Su) — follows parallel execution recommendation
- If #8 is INCLUDE → INCLUDE #22
- If #8 is OPTIONAL → OPTIONAL #22
- If #8 is SKIP → SKIP #22

**#23 Token-burn analyzer**
- Q5 includes Claude Code (A/B/C/D/E) → INCLUDE (reads `~/.claude` session logs; pairs with #17)
- Q5=F → OPTIONAL

**#24 MCP hygiene audit**
- Project uses any MCP servers/connectors → INCLUDE
- No MCP servers at all → OPTIONAL (harmless; warns only when something unused appears)

---

## Stage 3: User Selection

1. Wait for user response.
2. "looks good" → proceed with all recommendations as-is.
3. Specific changes (e.g., "3 include, 12 include") → apply overrides.
4. Confirm final selection:

```
FINAL SELECTION:
  INCLUDED: Core rules, Pass-by-reference, Planning protocol, ...
  SKIPPED:  Spin Jit Su, Heartbeat, ...

Generating project files now...
```

---

## Stage 4: Generate Output

### 4A: CLAUDE.md

Structure depends on whether #2 (pass-by-reference) is INCLUDED or SKIPPED.

**If INCLUDED (thin pointer — recommended for most projects):**

```markdown
# CLAUDE.md — [PROJECT NAME]

## Role
[Generated from Q1 — e.g., "You are a frontend developer building a marketing website for [company]."]
You follow the Agent Q framework.

## Context Loading
Before starting any task, read every file in `context/` and `workflows/`.
These contain your rules, planning protocols, engineering preferences, and operational workflows.
[If shared_context/ has content:] Also read `shared_context/` for domain knowledge.
Track all state in todo.md.

## Tool-Specific Notes (Claude Code)
- Use `Shift+Tab` to enter/exit Plan Mode for planning sessions.
- Use `/chrome` to open a browser for visual verification.
- Use `-dangerously-skip-permissions` flag for auto-accept execution (Phase 3).
- Use `/clear` to wipe context and start fresh.
- Use `/compact` to summarize and compress current context.

## Project Context
[Generated from Q1 description + Q2 tech stack]

## Tech Stack
[Generated from Q2]

## File Map
[Generated from actual project structure]

## Self-Awareness
You have permission to modify files in /tools/, /workflows/, and /context/ to
improve your own performance. If something isn't working, read your
own source code and fix it.

File map: CLAUDE.md (tool config), context/ (rules & preferences),
todo.md (state), workflows/ (SOPs), tools/ (scripts).
```

**If SKIPPED (all-in-one — for solo hobby + ship fast):**

Inline all selected rules directly into CLAUDE.md as numbered sections
(same approach as the Safqore website CLAUDE.md). Structure:

```markdown
# CLAUDE.md — [PROJECT NAME]

## Role
[Same as above]

## Project Context
[Same as above]

## Rules
### 1. Read State First
[From context/rules.md]

### 2. Plan Before Building
[Full 8-question or simplified 4-question, based on #3 selection]

### 3. 2-Strike Rule
[From context/rules.md]

### 4. When Unsure, Ask
[From context/rules.md]

[Include each selected feature as a numbered rule section]

## Tech Stack
[From Q2]

## File Map
[From project structure]
```

### 4B: Supporting Files

**Symlink** directories and shared files from the framework repo. Never copy.

```bash
# Run from the new project root:
FRAMEWORK=~/Documents/Projects/agent-q-framework

# Directories — always symlink whole dirs
ln -s "$FRAMEWORK/agents" ./agents
ln -s "$FRAMEWORK/context" ./context
ln -s "$FRAMEWORK/workflows" ./workflows
ln -s "$FRAMEWORK/tools" ./tools
ln -s "$FRAMEWORK/shared_context" ./shared_context

# Individual files
ln -s "$FRAMEWORK/soul.md" ./soul.md
ln -s "$FRAMEWORK/SKILL.md" ./SKILL.md
ln -s "$FRAMEWORK/CHEATSHEET.md" ./CHEATSHEET.md
ln -s "$FRAMEWORK/CONTRIBUTING.md" ./CONTRIBUTING.md

# Add to .gitignore so symlinks are never committed
cat >> .gitignore << 'EOF'

# Agent Q framework (symlinked from agent-q-framework/)
agents/
context/
workflows/
tools/
shared_context/
soul.md
SKILL.md
CHEATSHEET.md
CONTRIBUTING.md
EOF
```

**Project-specific build plans** should live in the project root (e.g., `build-plan-my-feature.md`), not inside the symlinked `workflows/` directory.

Feature-to-file mapping (all resolved via symlinks):

| Selected Feature | Files to Generate |
|-----------------|-------------------|
| #1 Core rules (always) | `todo.md` (initialized — see 4D below) |
| #2 Pass-by-reference | `context/rules.md`, plus any selected context/ files |
| #3 Planning protocol | `context/planning-protocol.md` (if #2 INCLUDED) |
| #4 Engineering prefs | `context/engineering-preferences.md` (if #2 INCLUDED) |
| #5 Frontend rules | `context/frontend.md` (if #2 INCLUDED) |
| #7 Code review | `workflows/code-review.md` |
| #8 Spin Jit Su | `workflows/spin-jit-su-workflow.md`, `tools/spin-jit-su.sh` |
| #10 Verification | `tools/verify.sh` (customize checks for project type) |
| #11 Heartbeat | `tools/heartbeat.sh` |
| #12 Soul.md | `soul.md` (template — agent fills in on first session) |
| #14 agent.md | `agent.md` |
| #15 copilot-instructions | `.github/copilot-instructions.md` |
| #16 agent-q.md | `.agent/rules/agent-q.md` |
| #17 Context monitor | `hooks/agentq-statusline.js`, `hooks/agentq-context-monitor.js`, `.claude/settings.json` |
| #18 Slash commands | `commands/q/` (9 command files, symlinked) |
| #19 Pause/Resume | `workflows/pause.md`, `workflows/resume.md` |
| #20 Debug workflow | `workflows/debug.md` |
| #21 Subagent roles | `agents/q-planner.md`, `agents/q-executor.md`, `agents/q-verifier.md`, `agents/q-debugger.md` |
| #22 Subagent spawning | Documented in `workflows/spin-jit-su-workflow.md` (requires #8) |
| #23 Token-burn analyzer | `tools/token-burn.py` (symlinked) |
| #24 MCP hygiene audit | `tools/mcp-audit.sh` (symlinked) + SessionStart hook in `.claude/settings.json` — see 4E |

### 4C: Document Exclusions

Add to the bottom of CLAUDE.md (or in todo.md under "Decisions Made"):

```markdown
## Setup Decisions
Features excluded during project setup (can be added later by copying
from the Agent Q framework repo):
- [Feature name] — [why it was skipped for this project]
- [Feature name] — [why it was skipped for this project]
```

### 4D: Initialize todo.md

```markdown
# [PROJECT NAME] — Project State

## Current Goal
- [ ] Complete setup — fill in project context, verify agent understands the project

## Active Tasks
- [ ] Describe the project so agent fills in Project Context in CLAUDE.md
- [ ] Create first workflow or build plan
- [ ] Run verification: "What is your role? What workflows? What is project state?"

## Completed
- [x] Project setup interview completed
- [x] Framework features selected: [comma-separated list of included features]

## Decisions Made
- Project type: [Q1 answer]
- Tech stack: [Q2 answer]
- Scale: [Q3 answer]
- Quality bar: [Q4 answer]
- AI tools: [Q5 answer]
- Features included: [list]
- Features excluded: [list with reasons]

## Known Issues
(none yet)

## Session Log
### Session 1
- Done: Project setup interview, feature selection, file generation
- Next: Fill in project context, create first build plan
- Blockers: None
```

### 4E: Token & MCP Hygiene Hooks (features #23–24)

These two tools read the user's **machine-wide** `~/.claude/` data (session logs and
connected MCP servers), not per-project files. They run from the symlinked `tools/`
directory but report on global state, so they're set up once and benefit every project.

**Dependency (token analysis):** the HUD's `usage` line and burn-rate reporting use
[`ccusage`](https://github.com/ryoppippi/ccusage). Install once per machine:
```bash
bun add -g ccusage      # or: npm i -g ccusage
```
The HUD degrades gracefully — it simply hides the `usage` line if `ccusage` is absent.

**Wire the MCP audit into SessionStart.** Merge this into the project's
`.claude/settings.json` (preserve any existing hooks — never replace the `hooks` block):
```json
{
  "hooks": {
    "SessionStart": [
      { "hooks": [ {
          "type": "command",
          "command": "bash $FRAMEWORK/tools/mcp-audit.sh --quiet",
          "timeout": 15
      } ] }
    ]
  }
}
```
Substitute `$FRAMEWORK` with the absolute framework path (e.g.
`~/Documents/Projects/agent-q-framework`) — hook commands cannot use shell variables.
After editing, validate: `jq -e '.hooks.SessionStart' .claude/settings.json`.

At each session start this prints one line **only if** a connected MCP server has never
been invoked:
```
⚠ unused MCP servers (never called): claude.ai Gmail, claude.ai Atlassian
```
It **reports only** — it never disconnects anything. claude.ai connectors are
account-managed, so disable them via `/mcp` or claude.ai → Settings → Connectors;
plugin MCPs are disabled in `enabledPlugins`.

**Manual use (any time):**
```bash
tools/token-burn.py --all     # rank heaviest sessions, then biggest token sinks within one
tools/token-burn.py --project <name> --top 20
tools/mcp-audit.sh            # full connected-vs-actually-used MCP report
```

> Note: the HUD itself (`tools/statusline-hud.sh`, feature #17) is registered in the
> user's **global** `~/.claude/settings.json` under `statusLine`, not per-project. The
> SessionStart hook above can live in either global or project settings — global makes
> the warning fire everywhere; project-level scopes it to this repo.

---

## Tools Used
- No external scripts. This workflow is purely conversational (agent asks, generates).

## Output
- `CLAUDE.md` — Customized for the project
- `todo.md` — Initialized with profile and first tasks
- Selected `context/` files (if pass-by-reference)
- Selected `workflows/` files
- Selected `tools/` scripts
- `soul.md` template (if selected)
- Additional tool configs (if selected)

## Success Criteria
- User answered all 5 profile questions (or deferred to recommendations) in under 3 minutes
- Feature menu was presented with clear recommendations and rationale for each
- User confirmed or modified the selection
- All selected files were generated with correct content
- Excluded features are documented with rationale
- Verification prompt succeeds: "What is your role? What workflows? What state?"

## Edge Cases
- **"Just give me everything"** — Set all to INCLUDE. Warn that heartbeat and verify.sh need project-specific customization.
- **"Just give me the minimum"** — Core rules only, all-in-one CLAUDE.md, everything else SKIP. Note what can be added later.
- **Contradictory answers** (e.g., ship-fast + mission-critical) — Point out the tension, ask which one wins.
- **Existing project (Q3=E)** — Don't overwrite existing files. Offer to merge Agent Q rules into existing config. Always recommend code review workflow.
- **Don't know stack yet** — Generate CLAUDE.md with placeholder sections, note in todo.md to fill in during first build session.
- **Want a feature but modified** — Generate base version, note customization as a task in todo.md.
