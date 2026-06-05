# Agent Q -- Codex Installation Guide

## Prerequisites

- OpenAI Codex CLI installed and authenticated
- Git available on PATH
- Node.js >= 18 (for hooks)

## Installation

### Option 1: Symlink-Based Discovery (Recommended)

Codex discovers skills via its skills directory. Symlink the framework there:

```bash
# Clone the framework
git clone https://github.com/muhammad83/agent-q-framework.git ~/.codex/skills/agent-q

# Verify the symlink resolves
ls ~/.codex/skills/agent-q/agent.md
```

### Option 2: Project-Local Installation

Copy the framework directly into your project:

```bash
git clone https://github.com/muhammad83/agent-q-framework.git /tmp/agent-q
cp -r /tmp/agent-q/* your-project/
rm -rf /tmp/agent-q
```

## Command Mapping

Codex uses its own command format. Agent Q commands map as follows:

| Agent Q Command | Codex Equivalent | Description |
|----------------|------------------|-------------|
| `/q:plan` | `@agent-q plan` | Structured planning with reverse elicitation |
| `/q:execute` | `@agent-q execute` | Execute build plan with deviation rules |
| `/q:verify` | `@agent-q verify` | Verify work against build plan |
| `/q:review` | `@agent-q review` | Structured code review |
| `/q:debug` | `@agent-q debug` | Scientific method debugging |
| `/q:quick` | `@agent-q quick` | Small fix without full planning |
| `/q:progress` | `@agent-q progress` | Show project state |
| `/q:pause` | `@agent-q pause` | Save session state |
| `/q:resume` | `@agent-q resume` | Resume paused session |
| `/q:orchestrate` | `@agent-q orchestrate` | Full multi-agent pipeline |
| `/q:spinjitsu` | `@agent-q spinjitsu` | Parallel execution |
| `/q:ingest` | `@agent-q ingest` | Media ingestion |

## Entry Point

Codex uses `agent.md` as the entry point. This file is already included in the framework root and points to the shared context in `context/`.

## Verification

After installation, verify the setup:

1. Start a Codex session in your project directory
2. Ask: "Read agent.md and describe your role"
3. The agent should reference Agent Q framework capabilities
4. Try: `@agent-q progress` to confirm command routing works

## Hooks

Codex does not support the same hook system as Claude Code. The framework hooks in `hooks/` are designed for Claude Code. For Codex, the context injection happens through `agent.md` directly.

To detect the platform at session start:

```bash
export CODEX_SESSION=1
source hooks/session-start.sh
```

## Known Limitations

- Codex does not support subagent spawning natively. The `/q:orchestrate` and `/q:spinjitsu` commands fall back to sequential inline execution.
- Codex does not support custom status line hooks. The `agentq-statusline.js` hook will not function.
- Session persistence across Codex restarts relies on `todo.md` state tracking.
