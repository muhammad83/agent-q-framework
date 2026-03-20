# Build Plan A: Multi-Agent Orchestration

## Goal
Add `/q:orchestrate` and `/q:spinjitsu` commands to Agent Q, enabling structured multi-agent pipelines and parallel execution from slash commands.

## Discovery Level
Level 1 — Quick verify. ECC patterns already researched.

## Tasks

### Task 1: Create orchestration protocol and `/q:orchestrate` command
- Create `workflows/orchestration-protocol.md` — defines handoff document format, agent chaining rules, parallel vs sequential logic, SHIP/NEEDS WORK/BLOCKED verdicts
- Create `.claude/commands/q/orchestrate.md` — slash command that reads the protocol, accepts a feature description, chains q-planner → q-executor → q-verifier → q-debugger (if needed)
- Handoff document format between agents:
  ```
  ## HANDOFF: [previous-agent] → [next-agent]
  ### Context
  ### Findings
  ### Files Modified
  ### Open Questions
  ### Recommendations
  ```
- Independent agents (e.g., q-verifier + security scan) run in parallel
- Final output: orchestration report with SHIP / NEEDS WORK / BLOCKED

### Task 2: Create `/q:spinjitsu` command
- Create `.claude/commands/q/spinjitsu.md` — slash command that:
  1. Detects all `workflows/build-plan-*.md` files
  2. Checks prerequisites (tmux, git, build plans finalized)
  3. Presents launch plan to user (which plans, which model per plan)
  4. Offers subagent spawning (single session) or tmux launch (multi-session)
  5. For subagent mode: spawns q-executor agents via Agent tool with `isolation: "worktree"`
  6. For tmux mode: generates the tmux commands or calls `tools/spin-jit-su.sh`
- Reference `workflows/spin-jit-su-workflow.md` for the full protocol

### Task 3: Update todo.md
- Record plan reference and status

## Files
| Action | File |
|---|---|
| Create | `workflows/orchestration-protocol.md` |
| Create | `.claude/commands/q/orchestrate.md` |
| Create | `.claude/commands/q/spinjitsu.md` |
| Modify | `todo.md` |

## Edge Cases
- Agent in chain fails → BLOCKED path with failure report
- Handoff documents too verbose → cap at 50 lines per handoff
- Circular failures (debugger can't fix → verifier fails again) → 2-attempt limit then BLOCKED

## Verification
- Run `/q:orchestrate` on a small test feature in this repo
- Run `/q:spinjitsu` and verify it detects build plans correctly

## Rollback
All new files. `git revert` or delete.
