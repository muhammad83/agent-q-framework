---
name: agent-q
description: A repeatable, tool-agnostic framework for building projects with AI coding agents
version: 1.1.0
author: Safqore
provides:
  - planning
  - execution
  - verification
  - debugging
  - orchestration
  - parallel-execution
  - tdd
  - code-review
  - brainstorm
  - media-ingestion
requires:
  - git
  - bash
  - node >= 18
extends: []
triggers:
  keywords: [agent q, planning, build plan, orchestrate, execute, verify, debug, spinjitsu, tdd, brainstorm, finish]
  files: [CLAUDE.md, agent.md, todo.md, soul.md, "workflows/*.md", "agents/*.md"]
platforms: [claude-code, cursor, codex, opencode, gemini-cli]
---

# Agent Q Framework

## Purpose

Agent Q is a deterministic, repeatable, tool-agnostic framework for building projects with AI coding agents. It provides structured workflows, deviation rules, and multi-agent orchestration so that any AI tool -- Claude Code, Cursor, OpenAI Codex, OpenCode, Gemini CLI, GitHub Copilot, Google Antigravity -- follows the same methodology and produces consistent results.

## Capabilities

- **Planning (Reverse Elicitation)** — Structured 8-question interview that extracts requirements before any code is written. The AI asks *you* questions, recommends answers, and builds a complete build plan.
- **Execution (Deviation Rules)** — Deterministic rules for when to auto-fix vs. stop and ask. Bugs get auto-fixed; architectural changes require approval. 3-attempt limit on auto-fixes.
- **Verification** — Goal-based verification that checks whether the *intent* was achieved, not just whether tasks were completed. Runs tests, visual checks, and logic audits.
- **Debugging (Scientific Method)** — Hypothesis-driven debugging workflow: observe, hypothesize, predict, test, conclude. No random changes.
- **Orchestration (Multi-Agent Pipeline)** — Chain q-planner, q-executor, q-verifier, and q-debugger with structured handoffs for end-to-end feature delivery.
- **Parallel Execution (Spin Jit Su)** -- Launch multiple build plans in parallel using tmux and subagent spawning for maximum throughput.
- **TDD Workflow** -- Red-green-refactor cycle with test-first development and automatic verification.
- **Brainstorm Mode** -- Structured ideation that produces actionable build plans, not just ideas.
- **Branch Finish** -- End-to-end branch completion: review, test, squash, merge.
- **Two-Stage Code Review** -- Automated first pass (lint, structure) followed by deep logic review.

## Agents

- **q-planner** — Creates detailed build plans using reverse elicitation and the planning protocol.
- **q-executor** — Executes build plans with deviation rules, atomic commits, and documentation updates.
- **q-verifier** — Verifies completed work against the build plan and quality standards.
- **q-debugger** — Debugs issues using the scientific method with structured hypothesis testing.

## Commands

| Command | Description | Autonomy | Namespace |
|---------|-------------|----------|-----------|
| `/q:plan` | Start a structured planning session with reverse elicitation | confirm | planning |
| `/q:execute` | Execute a build plan with deviation rules and atomic commits | confirm | execution |
| `/q:verify` | Verify completed work against the build plan and quality standards | auto | quality |
| `/q:review` | Run a structured code review on recent changes or a full codebase | auto | quality |
| `/q:debug` | Start a scientific method debugging session | confirm | quality |
| `/q:quick` | Apply a small, focused fix without full planning overhead | confirm | execution |
| `/q:progress` | Show current project state and recommend next actions | auto | dx |
| `/q:pause` | Save session state for clean handoff to next session | auto | dx |
| `/q:resume` | Resume from a paused session or start fresh from todo.md | auto | dx |
| `/q:orchestrate` | Run the full multi-agent pipeline (plan, execute, verify, debug) | confirm | execution |
| `/q:spinjitsu` | Launch parallel execution of multiple build plans | confirm | execution |
| `/q:ingest` | Ingest video/audio content for Agent Q context | confirm | dx |
| `/q:status` | Show all available /q: commands with descriptions | auto | dx |

## Installation

### Claude Code

Place the framework files in your project root. The `CLAUDE.md` file acts as the entry point. Commands are loaded from `.claude/commands/q/`.

```bash
git clone https://github.com/safqore/agent-q-framework.git my-project
```

Or install via the Agent Skills marketplace:

```
/plugin marketplace add safqore/agent-q-framework
```

### Cursor

Install via the Cursor plugin system. The `.cursor-plugin/plugin.json` file provides skill discovery metadata:

```bash
git clone https://github.com/safqore/agent-q-framework.git ~/.cursor/extensions/agent-q
```

See `.cursor-plugin/plugin.json` for activation triggers and command mapping.

### Codex CLI

Copy the framework to your Codex skills directory:

```bash
git clone https://github.com/safqore/agent-q-framework.git ~/.codex/skills/agent-q
```

The `agent.md` file in the repo root serves as the Codex entry point.

### OpenCode

Clone to your OpenCode skills directory:

```bash
git clone https://github.com/safqore/agent-q-framework.git ~/.opencode/skills/agent-q/
```

### Gemini CLI

Clone to the Gemini CLI extensions directory. Note: Gemini CLI does not support subagent spawning, so `/q:orchestrate` and `/q:spinjitsu` fall back to inline execution.

```bash
git clone https://github.com/safqore/agent-q-framework.git ~/.gemini/extensions/agent-q
export GEMINI_CLI=1
```

See `agents/gemini-cli-extension.md` for the full tool mapping and platform limitations.

### Manual

Clone the repo and copy the framework files into your project:

```bash
git clone https://github.com/safqore/agent-q-framework.git /tmp/agent-q
cp /tmp/agent-q/CLAUDE.md /tmp/agent-q/agent.md /tmp/agent-q/todo.md /tmp/agent-q/soul.md your-project/
cp -r /tmp/agent-q/context /tmp/agent-q/shared_context your-project/
cp -r /tmp/agent-q/workflows /tmp/agent-q/tools /tmp/agent-q/agents your-project/
cp -r /tmp/agent-q/.claude your-project/
```

## Resources

| Directory | Contents |
|-----------|----------|
| `context/` | Framework rules, planning protocol, engineering preferences, frontend rules |
| `workflows/` | Step-by-step operational workflows and build plans |
| `agents/` | Subagent role definitions (planner, executor, verifier, debugger) |
| `tools/` | Executable scripts (verify.sh, spin-jit-su.sh, heartbeat.sh) |
| `shared_context/` | Project-specific domain knowledge |
| `shared_context/ingested/` | Ingested video/audio transcripts and keyframes |
| `.claude/commands/q/` | Slash command definitions |
| `hooks/` | Platform detection and context injection hooks |
| `.cursor-plugin/` | Cursor plugin metadata |
| `.codex/` | Codex installation guide |
| `.opencode/` | OpenCode hook registration |

## Contributing a Skill

To add a new skill to Agent Q, follow the structure below. See `CONTRIBUTING.md` for the full guide.

### Required File Structure

Every skill consists of at minimum a workflow file and a command file:

```
workflows/{name}.md          -- Step-by-step workflow definition
.claude/commands/q/{name}.md -- Slash command that invokes the workflow
```

Optional additions:

```
agents/q-{name}.md           -- Subagent role definition (if the skill needs its own agent)
tools/{name}.sh              -- Executable script (if the skill needs automation)
```

### Naming Conventions

- Commands: `/q:{name}` (lowercase, no spaces, no underscores)
- Workflow files: `workflows/{name}.md` (match the command name)
- Agent files: `agents/q-{name}.md` (prefix with `q-`)
- Tool scripts: `tools/{name}.sh` (match the command name)

### Required Metadata

Every workflow file must include a YAML frontmatter block:

```yaml
---
name: {name}
description: One-line description of what this skill does
autonomy: auto | confirm
namespace: planning | execution | quality | dx
triggers:
  keywords: [list, of, activation, keywords]
  files: [optional, file, patterns]
---
```

### Testing Requirements

Before submitting a new skill:

1. Manual verification: run the skill end-to-end on a test project
2. Verify the command is listed in `/q:status` output
3. Verify the skill loads on demand (no eager context loading)
4. Verify the skill updates `todo.md` when appropriate
5. Run `/q:review` on the skill files themselves

## Skill Discovery

Platforms discover and load Agent Q skills through their native mechanisms:

| Platform | Discovery Mechanism | Config File |
|----------|-------------------|-------------|
| Claude Code | `.claude/commands/q/` directory + `CLAUDE.md` on-demand loading | `CLAUDE.md` |
| Cursor | `.cursor-plugin/plugin.json` activation triggers | `.cursor-plugin/plugin.json` |
| Codex | Symlink in `~/.codex/skills/` + `agent.md` entry point | `.codex/setup.md` |
| OpenCode | `.opencode/config.json` hook auto-registration | `.opencode/config.json` |
| Gemini CLI | `~/.gemini/extensions/` directory + tool declarations | `agents/gemini-cli-extension.md` |

### Activation Triggers

Skills activate based on two signal types:

1. **File patterns** -- when specific files exist in the project (e.g., `CLAUDE.md`, `todo.md`, `workflows/*.md`)
2. **Keyword triggers** -- when the user mentions specific terms (e.g., "agent q", "/q:plan", "build plan")

### Hook Registration

The `hooks/session-start.sh` script detects the current platform and outputs context injection variables. Platforms that support session-start hooks should run this script automatically. Platforms that do not support hooks rely on their entry point file (`CLAUDE.md`, `agent.md`, etc.) for context loading.
