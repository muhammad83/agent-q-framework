---
plan: superpowers-dx
status: pending
stream: B
parallel: true
discovery: 1
---

# Build Plan — Superpowers DX Integration

Cherry-pick visual brainstorming companion and finishing branch workflow from Superpowers into Agent Q.

## Decisions

- Visual brainstorm is a zero-dependency Node.js WebSocket server in `tools/`
- Uses native Node.js `http` module + WebSocket protocol — no npm packages
- Auto-terminates after 30 min idle or when parent PID dies
- Port configurable via `AGENTQ_BRAINSTORM_PORT` (default: 3847)
- Finish branch workflow presents 4 options: merge locally, create PR, keep branch, discard
- Runs verification before offering completion options

## Task 1 — Visual Brainstorming Companion + Command

**Create:** `tools/visual-brainstorm.cjs`
- Zero-dependency Node.js WebSocket server
- Serves HTML page with:
  - Mockup rendering area (SVG-based simple diagramming)
  - Markdown preview panel
  - Live updates via WebSocket from agent
- Safety features:
  - 30-minute idle timeout (configurable via `AGENTQ_BRAINSTORM_TIMEOUT`)
  - Parent PID monitoring — if parent dies, server shuts down
  - Binds to localhost only (127.0.0.1)
- Port: `AGENTQ_BRAINSTORM_PORT` env var, default 3847
- Agent sends content updates as JSON messages: `{ type: "mockup" | "markdown" | "diagram", content: "..." }`
- Browser renders content in real-time

**Create:** `.claude/commands/q/brainstorm.md`
- Autonomy: confirm
- Namespace: planning
- Starts visual brainstorm server via `tools/visual-brainstorm.cjs`
- Opens browser to localhost:3847
- Conducts divergent exploration:
  - Asks clarifying questions one at a time
  - Explores 2-3 different approaches with trade-offs
  - Sends mockups/diagrams to browser for visual topics
  - Presents design in digestible sections
- Per-question decision: visual (send to browser) or terminal (text response)
- Outputs a spec document to `docs/specs/` when brainstorm concludes
- Shuts down server on completion

**Verify:** Run `/q:brainstorm`. Confirm server starts, browser opens, content renders. Kill parent process — confirm server dies within timeout. Confirm spec document is generated.

## Task 2 — Finish Branch Workflow + Command

**Create:** `workflows/finish-branch.md`
- Pre-completion checklist:
  1. Run test suite — all tests must pass
  2. Run linter/formatter if configured
  3. Check for uncommitted changes — commit or stash
  4. Verify branch is up to date with base branch
- Present 4 options to user:
  - **Merge locally:** `git checkout main && git merge <branch>`
  - **Create PR:** `gh pr create` with auto-generated title/body from commits
  - **Keep branch:** Leave as-is for later (just report status)
  - **Discard:** `git checkout main && git branch -D <branch>` (requires explicit confirmation)
- Post-completion cleanup:
  - If merge: delete feature branch
  - If PR: report PR URL
  - If keep: report branch status
  - If discard: confirm deletion
- Update `todo.md` with completion status

**Create:** `.claude/commands/q/finish.md`
- Autonomy: confirm
- Namespace: dx
- Loads `workflows/finish-branch.md`
- Detects current branch, counts commits ahead of main
- Runs pre-completion checklist
- Presents options with context (e.g., "3 commits ahead of main, all tests passing")
- Executes chosen option
- Updates todo.md

**Verify:** Create a test branch with commits. Run `/q:finish`. Confirm pre-completion checks run, 4 options presented, chosen option executes correctly. Test the discard path requires explicit confirmation.

## Edge Cases

- Visual brainstorm: port already in use → detect and suggest alternative port
- Visual brainstorm: no browser available (headless/SSH) → fall back to terminal-only mode with message
- Finish branch: on main branch → reject with message "already on main, nothing to finish"
- Finish branch: uncommitted changes → prompt to commit or stash before proceeding
- Finish branch: merge conflicts → report conflict, don't auto-resolve, let user decide

## Rollback

- Task 1: delete `tools/visual-brainstorm.cjs` + `.claude/commands/q/brainstorm.md`
- Task 2: delete `workflows/finish-branch.md` + `.claude/commands/q/finish.md`
- Both tasks are entirely new files — zero risk to existing functionality
