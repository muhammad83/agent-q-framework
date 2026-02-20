# Agent Q Framework — Repeatable Claude Code Project Starter

A deterministic, repeatable framework for building projects with Claude Code.
Based on the Agent Q methodology (Workflows, Agents, Tools).

## How to Use This

### Starting a New Project

1. Clone this repo: `git clone https://github.com/safqore/agent-q-framework.git my-project-name`
2. Reset git: `cd my-project-name && rm -rf .git && git init`
3. Copy `.env.example` to `.env` and add your API keys
4. Start Claude (`claude`) and describe your project — Claude fills in `CLAUDE.md` and `todo.md` for you
5. Follow the Phase 1 and Phase 2 checklists below

### Adding to an Existing Project

1. Clone this repo somewhere temporary: `git clone https://github.com/safqore/agent-q-framework.git /tmp/agent-q`
2. Copy the framework files into your project:
   ```bash
   cp /tmp/agent-q/CLAUDE.md /tmp/agent-q/todo.md /tmp/agent-q/soul.md your-project/
   cp /tmp/agent-q/CHEATSHEET.md /tmp/agent-q/QUICKSTART.md your-project/
   cp -r /tmp/agent-q/workflows /tmp/agent-q/tools /tmp/agent-q/rules your-project/
   cp /tmp/agent-q/.env.example your-project/
   ```
3. Copy `.env.example` to `.env` and add your API keys
4. Start Claude (`claude`) and tell it: "This is an existing project. Read the codebase and fill in CLAUDE.md and todo.md based on what already exists."
5. Use Phase 2B (Code Review) to review your existing code, or Phase 2A to plan new features

### Folder Structure

```
your-project/
├── CLAUDE.md              ← Agent rules & config (the brain)
├── CHEATSHEET.md          ← Prompts & commands for every phase
├── QUICKSTART.md          ← 5-minute new project guide
├── README.md              ← This file
├── soul.md                ← Agent personality (the agent writes its own)
├── todo.md                ← Project state tracker (the memory)
├── setup.sh               ← New project setup script
├── .env.example           ← API key template (copy to .env)
├── .gitignore             ← Keeps secrets and junk out of git
├── workflows/             ← Step-by-step instructions (SOPs)
│   ├── _TEMPLATE.md       ← Copy this for every new workflow
│   ├── code-review.md     ← Phase 2B code review workflow
│   └── starcraft-workflow.md ← Parallel execution workflow
├── tools/                 ← Executable scripts
│   ├── verify.sh          ← Boolean pass/fail checks on output files
│   └── heartbeat.sh       ← Proactive monitoring (optional, cron-friendly)
├── rules/                 ← Engineering rules for Claude
│   └── _TEMPLATE.md       ← Copy this for every new rule
├── clients/               ← Per-client data (if applicable)
└── templates/             ← Reusable templates for docs/trackers
```

### Phase 1 Checklist (Setup)

- [ ] Clone this repo and rename folder (or copy framework files into existing project)
- [ ] Copy `.env.example` to `.env` and add your API keys
- [ ] Start Claude and describe your project — Claude fills in CLAUDE.md and todo.md
- [ ] Create your first workflow file in /workflows
- [ ] Verify: run `claude` and ask it to read CLAUDE.md and describe its role

### Phase 2 Checklist (Planning)

- [ ] Start Claude Code: `claude`
- [ ] Enter Plan Mode: `Shift+Tab`
- [ ] Paste the Reverse Elicitation Prompt (see below)
- [ ] Answer all of Claude's questions
- [ ] Tell Claude to write the plan file to `workflows/build-plan-{feature-name}.md`
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
