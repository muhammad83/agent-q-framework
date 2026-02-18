# Agent Q Framework — Repeatable Claude Code Project Starter

A deterministic, repeatable framework for building projects with Claude Code.
Based on the Agent Q methodology (Workflows, Agents, Tools).

## How to Use This

### Starting a New Project

1. Clone this repo
2. Rename the folder to your project name
3. Open `CLAUDE.md` and fill in the `[PLACEHOLDERS]`
4. Open `todo.md` and fill in your project name and first goal
5. Follow the Phase 1 and Phase 2 checklists below

### Folder Structure

```
your-project/
├── CLAUDE.md              ← Agent configuration (the brain)
├── todo.md                ← Project state tracker (the memory)
├── .env                   ← Secrets (never commit this)
├── .gitignore             ← Keeps secrets and junk out of git
├── workflows/             ← Step-by-step instructions (SOPs)
│   └── _TEMPLATE.md       ← Copy this for every new workflow
├── tools/                 ← Executable scripts (Python, JS, etc)
├── clients/               ← Per-client data (if applicable)
└── templates/             ← Reusable templates for docs/trackers
```

### Phase 1 Checklist (Setup)

- [ ] Clone this repo and rename folder
- [ ] Fill in CLAUDE.md with project role, rules, and frameworks
- [ ] Fill in todo.md with first goal
- [ ] Add your API keys to .env
- [ ] Create your first workflow file in /workflows
- [ ] Verify: run `claude` and ask it to read CLAUDE.md and describe its role

### Phase 2 Checklist (Planning)

- [ ] Start Claude Code: `claude`
- [ ] Enter Plan Mode: `Shift+Tab`
- [ ] Paste the Reverse Elicitation Prompt (see below)
- [ ] Answer all of Claude's questions
- [ ] Tell Claude to write the plan file
- [ ] Review plan with `Ctrl+G`
- [ ] Edit anything you disagree with
- [ ] Exit Plan Mode: `Shift+Tab`
- [ ] Tell Claude to execute the plan

### The Reverse Elicitation Prompt (Copy-Paste This Every Time)

```
Read CLAUDE.md and all files in /workflows.

[YOUR 2-3 SENTENCE PROJECT DESCRIPTION HERE]

Interview me in detail about technical decisions, implementation
details, edge cases, UI/UX concerns, and trade-offs. Do not write
any code. Just ask me questions until you fully understand what
to build.

For each question:
- Give me your recommended answer and why.
- Then ask if I agree or want something different.
- If I say "you decide" or "not sure", go with your recommendation
  and move on.

After all questions are answered, summarize every decision we made
before writing the plan.
```

### Phase 3: Execution (StarCraft Method)

Once the plan is approved:
- Tab 1: `claude -dangerously-skip-permissions` (Builder)
- Tab 2: `tail -f logs | claude` or run tests (Verifier)
- Use `/clear` often to keep context clean
- 2-Strike Rule: If you correct Claude twice on the same thing, 
  kill the session and restart fresh

### Phase 4: Verification & Deployment

- Visual check: Use `/chrome` to verify UI
- Logic check: Post-write hooks run tests automatically
- Deploy: Push to Modal, Railway, or Render
- Security: Always run a security audit before deploying
