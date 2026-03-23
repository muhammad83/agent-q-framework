---
name: agent-q
description: A repeatable, tool-agnostic framework for building projects with AI coding agents
version: 1.0.0
author: Safqore
triggers:
  keywords: [agent q, planning, build plan, orchestrate, execute, verify, debug, spinjitsu, domain-specialists, security, frontend, research]
  files: [CLAUDE.md, agent.md, todo.md, soul.md]
---

# Agent Q Framework

## Purpose

Agent Q is a deterministic, repeatable, tool-agnostic framework for building projects with AI coding agents. It provides structured workflows, deviation rules, and multi-agent orchestration so that any AI tool — Claude Code, OpenAI Codex, GitHub Copilot, Google Antigravity — follows the same methodology and produces consistent results.

## Capabilities

- **Planning (Reverse Elicitation)** — Structured 8-question interview that extracts requirements before any code is written. The AI asks *you* questions, recommends answers, and builds a complete build plan.
- **Execution (Deviation Rules)** — Deterministic rules for when to auto-fix vs. stop and ask. Bugs get auto-fixed; architectural changes require approval. 3-attempt limit on auto-fixes.
- **Verification** — Goal-based verification that checks whether the *intent* was achieved, not just whether tasks were completed. Runs tests, visual checks, and logic audits.
- **Debugging (Scientific Method)** — Hypothesis-driven debugging workflow: observe, hypothesize, predict, test, conclude. No random changes.
- **Orchestration (Multi-Agent Pipeline)** — Chain q-planner, q-executor, q-verifier, and q-debugger with structured handoffs for end-to-end feature delivery.
- **Parallel Execution (Spin Jit Su)** — Launch multiple build plans in parallel using tmux and subagent spawning for maximum throughput.
- **Domain Specialists** — Specialist agents (security, frontend, researcher) that advise alongside the core pipeline with trigger-based routing and priority ordering.

## Agents

- **q-planner** — Creates detailed build plans using reverse elicitation and the planning protocol.
- **q-executor** — Executes build plans with deviation rules, atomic commits, and documentation updates.
- **q-verifier** — Verifies completed work against the build plan and quality standards.
- **q-debugger** — Debugs issues using the scientific method with structured hypothesis testing.
- **q-security** — Reviews code for OWASP Top 10 vulnerabilities, auth/authz weaknesses, and secrets exposure.
- **q-frontend** — Audits UI code for WCAG 2.1 accessibility, component quality, responsive design, and performance.
- **q-researcher** — Conducts structured investigations with comparison matrices and ranked recommendations.

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
| `agents/` | Subagent role definitions (planner, executor, verifier, debugger) and domain specialists (security, frontend, researcher) |
| `tools/` | Executable scripts (verify.sh, spin-jit-su.sh, heartbeat.sh) |
| `shared_context/` | Project-specific domain knowledge |
| `shared_context/ingested/` | Ingested video/audio transcripts and keyframes |
| `.claude/commands/q/` | Slash command definitions |
