# Workflow: StarCraft Method (Parallel Claude Code Execution)

## When to Use

Run this when you have **2 or more projects** that are past planning/code review
(Phase 2A/2B) and have concrete things to build. Each project needs a finalized
build plan in `workflows/build-plan-{feature}.md` before you launch.

Don't use this for a single project — you'll just add overhead without
parallelism. The benefit comes from keeping multiple Claude instances building
while you rotate between them as the human-in-the-loop.

## Context Needed

Before running, make sure you have:
- [ ] 2+ projects with finalized build plans
- [ ] Each project has a working `CLAUDE.md` and `todo.md`
- [ ] Git repos initialized (worktrees or separate repos — see Setup below)
- [ ] `tmux` installed (`brew install tmux` on macOS)
- [ ] API budget estimated (see Token Budget below)

## Model Strategy

Use different models for different jobs. This is where the cost savings come from.

| Role | Model | Alias | Cost (per M tokens in/out) | When |
|------|-------|-------|----------------------------|------|
| **Planning** | Claude Opus 4.6 | `opusplan` | $15 / $75 | Phase 2A/2B interviews, architecture |
| **Building** | Claude Sonnet 4.6 | (default) | $3 / $15 | Phase 3 execution, writing code |
| **Verification** | Claude Opus 4.6 | `opusplan` | $15 / $75 | Code review, bug hunting, final QA |

Sonnet 4.6 is **5x cheaper** than Opus on input and output. For long build
sessions where the agent is writing hundreds of lines, this adds up fast.

### Set up the alias

Add to your shell config (`~/.zshrc` or `~/.bashrc`):

```bash
alias opusplan="claude --model claude-opus-4-6"
```

### The pattern

```
Plan with Opus → Build with Sonnet → Verify with Opus
```

You're buying the expensive brain for the decisions that matter (architecture,
review) and using the fast brain for the mechanical work (writing code from
a clear plan).

## Setup

### Option A: Git Worktrees (same repo, different features)

Best when you're building multiple features in one codebase:

```bash
# From your main repo
git worktree add ../project-feature-a feature-a
git worktree add ../project-feature-b feature-b
git worktree add ../project-feature-c feature-c
```

Each worktree gets its own directory, its own branch, and its own Claude
instance. They share git history but won't step on each other's files.

### Option B: Separate Repos (different projects)

If you're working across unrelated projects, just `cd` into each one.
No special setup needed.

## Steps

### 1. Prepare Each Project

For every project you're about to run in parallel:

```bash
# In each project directory
claude
> Read CLAUDE.md and todo.md. Confirm the build plan is ready.
> exit
```

Make sure each project has:
- A clear build plan in `workflows/build-plan-{feature}.md`
- A current `todo.md` with the next tasks listed
- No uncommitted changes that could conflict

### 2. Launch with tmux

```bash
# Create a named tmux session
tmux new-session -s starcraft

# Split into panes (for 2-4 projects)
# Ctrl+B then % for vertical split
# Ctrl+B then " for horizontal split

# Or use named windows (better for 5+)
tmux new-window -n project-a
tmux new-window -n project-b
tmux new-window -n project-c
```

**tmux essentials:**
- `Ctrl+B` then number → switch to window
- `Ctrl+B` then `n` / `p` → next / previous window
- `Ctrl+B` then `d` → detach (session keeps running)
- `tmux attach -t starcraft` → reattach

### 3. Kick Off Builds

In each pane/window, start Claude with auto-accept:

```bash
cd /path/to/project-a
claude --dangerously-skip-permissions
```

Then paste the build prompt:

```
Read workflows/build-plan-{feature}.md and execute it fully.
Update todo.md as you go.
```

Repeat for each project. Now they're all building simultaneously.

### 4. Rotate Every 5-10 Minutes

This is the StarCraft part. You're the commander — check each base regularly:

- **Glance** at the output. Is it making progress or stuck?
- **Steer** if it's going off-track: "Stop. That's wrong. Do X instead."
- **Unblock** if it's asking a question or hit an error.
- **Move on** to the next instance.

Don't micromanage. If an instance is happily building, let it cook. Spend
your time on whichever instance needs human input.

### 5. Verify with Opus

Once an instance finishes building, switch to Opus for verification:

```bash
# Start a new session with Opus
opusplan
```

```
Read CLAUDE.md, todo.md, and all files modified in the last session.
Review the code for:
1. Bugs and logic errors
2. Security issues
3. Missing edge cases
4. Deviations from the build plan
Give me a numbered list of issues found.
```

Fix anything it catches, then move to Phase 4 (deployment).

### 6. Merge and Clean Up

```bash
# If using worktrees
cd /path/to/main-repo
git merge feature-a
git merge feature-b
git worktree remove ../project-feature-a
git worktree remove ../project-feature-b

# Kill the tmux session when done
tmux kill-session -t starcraft
```

## Scaling Rules

| Projects | Strategy |
|----------|----------|
| **1** | Don't use this workflow. Just build normally. |
| **2-4** | Standard tmux panes. Split screen, rotate between them. |
| **5-8** | tmux named windows (`Ctrl+B` then number to switch). One project per window. |
| **8+** | Cloud sessions with `&` prefix (see Mobile Control below). |

### Why the tiers matter

- **2-4**: You can see all panes at once. Easy to spot when one needs attention.
- **5-8**: Too many panes to see at once. Named windows let you jump by number.
- **8+**: Your local machine becomes the bottleneck. Offload to cloud sessions.

## Google Antigravity Alternative

If you're using **Google Antigravity**, you can skip tmux entirely. Antigravity's
**Manager view** is a built-in control center for orchestrating multiple agents
working in parallel across workspaces. It provides:
- A dashboard showing all active agents and their progress
- Ability to steer, pause, or restart any agent from one interface
- Asynchronous task execution across multiple workspaces

To use: open Manager view, create an agent per project, point each to its
`workflows/build-plan-{feature}.md`, and rotate between them in the dashboard.
The same model strategy applies (use Gemini 3 Flash or Sonnet for building,
Deep Think or Opus for planning/review).

## Mobile Control

### Cloud Sessions (`&` prefix)

For 8+ projects or when you want to manage from your phone:

```bash
# Start a cloud session
& claude --dangerously-skip-permissions
```

The `&` prefix runs the session on Anthropic's cloud. You get a URL you can
open from any device — including your phone.

### Happy Coder (Alternative)

[Happy Coder](https://happycoder.ai) is a mobile app that gives you a
chat interface to your Claude Code sessions. Good for:
- Monitoring multiple sessions from your phone
- Sending quick steering commands while away from your desk
- Getting notifications when an instance needs input

## Edge Cases

### Context limit hit mid-build

Claude will auto-compact when approaching the limit. If you notice quality
degrading:

```
/compact
```

Or if it's really lost:

```
/clear
Read todo.md. Continue from where we left off.
```

The key is that `todo.md` acts as external memory. As long as todo.md is
current, a fresh context can pick up where the last one stopped.

### Shared dependency conflicts (worktrees)

If two worktrees modify the same dependency file (`package.json`,
`requirements.txt`, `go.mod`):

1. Don't let both instances modify dependencies at the same time
2. Pick one as the "dependency owner" — only that instance adds packages
3. The other instance works with what's already installed
4. Resolve conflicts at merge time, not during build

### Instance going off-track

Signs: it's writing code you didn't ask for, refactoring things that work,
or ignoring the build plan.

**Fix it fast:**
```
Stop. Read workflows/build-plan-{feature}.md again.
You're off-plan. The current task is: [specific task].
Do only that. Nothing else.
```

If it keeps drifting after 2 corrections (2-Strike Rule):
```
Ctrl+C
/clear
Read todo.md. The next task is [specific task]. Build only that.
```

### Token budget

Rough cost estimates per project per session:

| Model | Typical session | Cost estimate |
|-------|----------------|---------------|
| Sonnet 4.6 (building) | ~200K in / ~50K out tokens | ~$1.35 |
| Opus 4.6 (planning/review) | ~100K in / ~20K out tokens | ~$3.00 |

For 4 parallel projects with plan → build → verify:
- 4x Sonnet build sessions: ~$5.40
- 4x Opus verify sessions: ~$12.00
- Total: ~$17.40

Compare to running everything on Opus: ~$48+. The model strategy saves
roughly 60%.

## CLAUDE.md Addition for Parallel Execution

Add this block to each project's `CLAUDE.md` when running in StarCraft mode:

```markdown
## Parallel Execution
This project may be running alongside other Claude Code instances.
- Do NOT modify files outside your project directory.
- Do NOT run commands that affect global state (global npm install, etc.).
- If you need a shared resource, note it in todo.md and ask — don't grab it.
- Keep your changes on your own branch. Do not push to main.
```

## Cheatsheet Entry

Add to `CHEATSHEET.md` under Phase 3:

```markdown
## PHASE 3+: STARCRAFT (PARALLEL EXECUTION)

Full workflow: `workflows/starcraft-workflow.md`

### Quick Start
1. Finalize build plans for 2+ projects
2. `tmux new-session -s starcraft`
3. Open a window per project, start `claude --dangerously-skip-permissions`
4. Kick off builds, rotate every 5-10 min
5. Verify each with `opusplan` when done
6. Merge, clean up worktrees, kill tmux session

### Model Alias
```bash
alias opusplan="claude --model claude-opus-4-6"
```

### Cost Rule
Plan with Opus → Build with Sonnet → Verify with Opus = ~60% savings
```

## Tools Used

- `tmux` for session management
- `git worktree` for parallel branches
- `claude --dangerously-skip-permissions` for auto-accept builds
- `opusplan` alias for Opus planning/verification sessions

## Output

- Multiple features built in parallel across separate Claude instances
- Verified code on separate branches ready to merge
- Updated `todo.md` in each project

## Success Criteria

- All parallel builds complete without blocking each other
- Each build passes Opus verification with no critical issues
- Branches merge cleanly (or conflicts are resolved)
- Total wall-clock time is significantly less than building sequentially
- Token spend stays within the budgeted model strategy (Sonnet for build, Opus for verify)
