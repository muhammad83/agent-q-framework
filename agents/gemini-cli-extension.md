---
name: agent-q-gemini-cli
platform: gemini-cli
format: native-extension
version: 1.1.0
---

# Agent Q -- Gemini CLI Extension

## Overview

This file maps Agent Q capabilities to Gemini CLI's native tool declaration format. Gemini CLI discovers extensions through its configuration directory and activates them based on tool declarations below.

## Installation

```bash
# Clone the framework into Gemini CLI's extensions directory
git clone https://github.com/safqore/agent-q-framework.git ~/.gemini/extensions/agent-q

# Set the environment variable for platform detection
export GEMINI_CLI=1
```

## Tool Declarations

### Planning

| Tool | Description | Entry Point |
|------|-------------|-------------|
| `agentq_plan` | Structured planning with reverse elicitation interview | `context/planning-protocol.md` |
| `agentq_quick` | Small, focused fix without full planning overhead | inline |

### Execution

| Tool | Description | Entry Point |
|------|-------------|-------------|
| `agentq_execute` | Execute build plan with deviation rules and atomic commits | `agents/q-executor.md` |
| `agentq_orchestrate` | Full pipeline (plan, execute, verify, debug) -- inline mode | `workflows/orchestration-protocol.md` |
| `agentq_spinjitsu` | Parallel execution -- inline mode (no subagent support) | `workflows/spin-jit-su-workflow.md` |

### Quality

| Tool | Description | Entry Point |
|------|-------------|-------------|
| `agentq_verify` | Verify completed work against the build plan | `agents/q-verifier.md` |
| `agentq_review` | Structured code review (4-section format) | `workflows/code-review.md` |
| `agentq_debug` | Scientific method debugging with hypothesis testing | `workflows/debug.md` |

### Developer Experience

| Tool | Description | Entry Point |
|------|-------------|-------------|
| `agentq_progress` | Show current project state and recommend next actions | `todo.md` |
| `agentq_pause` | Save session state for clean handoff | `workflows/pause.md` |
| `agentq_resume` | Resume from a paused session | `workflows/resume.md` |
| `agentq_ingest` | Ingest video/audio content for context | `tools/ingest.sh` |

## Platform Limitations

Gemini CLI does not support subagent spawning. The following commands behave differently:

| Command | Normal Behavior | Gemini CLI Fallback |
|---------|----------------|---------------------|
| `agentq_orchestrate` | Spawns q-planner, q-executor, q-verifier, q-debugger as subagents | Runs all four roles inline in sequence within a single session |
| `agentq_spinjitsu` | Launches parallel tmux sessions or subagent streams | Runs plans sequentially in a single session (no parallelism) |

This follows the Superpowers pattern: degrade gracefully rather than fail. The same methodology applies; only the execution model changes.

## Context Loading

Gemini CLI should load the following files at session start:

- `CLAUDE.md` -- framework configuration and on-demand loading map
- `soul.md` -- agent personality
- `todo.md` -- current project state
- `SKILL.md` -- skill metadata and capability declarations

All other files are loaded on demand based on the task at hand. See CLAUDE.md for the full on-demand loading table.

## State Tracking

All state is tracked in `todo.md`. Gemini CLI sessions should read this file at the start of every session and update it after completing tasks. This is the handoff mechanism between sessions and between platforms.
