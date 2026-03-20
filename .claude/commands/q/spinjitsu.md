---
name: q:spinjitsu
description: Launch parallel execution of multiple build plans using Spin Jit Su
triggers: [spinjitsu, parallel, concurrent, multi-agent launch]
argument-hint: "[optional: specific build plan files]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

## Objective
Launch parallel execution of multiple build plans using the Spin Jit Su method.

## Input
Optional specific plans: $ARGUMENTS
If no arguments, auto-detect all `workflows/build-plan-*.md` files.

## Execution Context
- Read `workflows/spin-jit-su-workflow.md` for the full protocol
- Read `todo.md` for current project state
- Read `context/rules.md` for coding standards

## Process

1. **Detect build plans.**
   - If $ARGUMENTS provided, use those specific plan files.
   - Otherwise, glob for `workflows/build-plan-*.md`.
   - If no plans found, tell the user: "No build plans found. Run /q:plan first."

2. **Check prerequisites.**
   - Each plan file exists and is readable
   - `todo.md` is current
   - Git working tree is clean (warn if uncommitted changes)

3. **Present launch plan.** Show the user:
   ```
   SPIN JIT SU — Launch Plan
   ========================
   [1] build-plan-{name}.md — {summary of goal}
   [2] build-plan-{name}.md — {summary of goal}
   ...
   Mode: [subagent / tmux]
   ```
   Ask the user which mode and confirm before launching.

4. **Mode A — Subagent spawning (recommended for same-repo work).**
   For each build plan:
   - Read `agents/q-executor.md` for the executor role
   - Spawn an Agent (subagent_type: "general-purpose") with `isolation: "worktree"`
   - Pass the full build plan content as the prompt
   - Include instructions to read `context/rules.md` and follow deviation rules
   - Launch all agents in parallel (single message, multiple Agent tool calls)
   - Collect results as they complete
   - Report summary of each stream

5. **Mode B — tmux (recommended for multi-repo or long builds).**
   Generate the tmux launch commands:
   ```bash
   ./tools/spin-jit-su.sh workflows/build-plan-{a}.md workflows/build-plan-{b}.md
   ```
   Or if the script doesn't exist, generate manual tmux commands:
   ```bash
   tmux new-session -s spinjitsu -n plan-a -d
   tmux send-keys -t spinjitsu:plan-a 'cd /path && claude --dangerously-skip-permissions' Enter
   tmux new-window -t spinjitsu -n plan-b
   tmux send-keys -t spinjitsu:plan-b 'cd /path && claude --dangerously-skip-permissions' Enter
   tmux attach -t spinjitsu
   ```
   Present commands to user for execution.

6. **Collect and report.**
   - For subagent mode: wait for all agents, collect results, present summary
   - For tmux mode: remind user to rotate every 5-10 min and verify with Opus when done
   - Update `todo.md` with results

## Scaling Rules
| Plans | Recommendation |
|-------|---------------|
| 1 | Don't use this. Just run `/q:execute`. |
| 2-4 | Subagent mode or tmux panes |
| 5-8 | tmux named windows |
| 8+ | tmux + cloud sessions |

## Success Criteria
- All build plans detected and presented
- User confirmed launch mode
- All parallel streams launched
- Results collected and summarized
- todo.md updated
