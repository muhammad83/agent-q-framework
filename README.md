# Agent Q Framework — Repeatable AI-Assisted Project Starter

A deterministic, repeatable, tool-agnostic framework for building projects with AI coding agents.
Based on the Agent Q methodology (Workflows, Agents, Tools).

Works with **Claude Code**, **OpenAI Codex**, **GitHub Copilot**, **Google Antigravity**, and any future AI tool that reads markdown instructions.

## Architecture: Pass by Reference

Agent Q uses a two-tier "pass by reference" architecture. Instead of duplicating rules inside each tool's config file, all tools point to the same shared context:

```
┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  ┌──────────────┐
│  CLAUDE.md  │  │  agent.md   │  │ .github/copilot- │  │ .agent/rules/│
│(Claude Code)│  │(OpenAI Codex)│  │ instructions.md  │  │ agent-q.md   │
│             │  │             │  │(GitHub Copilot)  │  │(Antigravity) │
└──────┬──────┘  └──────┬──────┘  └────────┬────────┘  └──────┬───────┘
       │                │                   │                  │
       └────────────────┴───────────────────┴──────────────────┘
                                  │
                                  ▼
              ┌─────────────────┐
              │    context/     │  ← Framework rules (same for every project)
              │  rules.md       │
              │  planning-      │
              │   protocol.md   │
              │  engineering-   │
              │   preferences.md│
              │  frontend.md    │
              └─────────────────┘
              ┌─────────────────┐
              │ shared_context/ │  ← Project-specific domain knowledge
              │  (personas,     │    (unique to THIS project)
              │   frameworks,   │
              │   domain rules) │
              └─────────────────┘
              ┌─────────────────┐
              │   workflows/    │  ← Operational workflows & build plans
              └─────────────────┘
```

**context/** contains framework-level rules that apply to every Agent Q project: engineering rules, planning protocols, coding preferences, and frontend conventions. These are the same regardless of which AI tool runs them.

**shared_context/** contains project-specific domain knowledge: personas, analysis frameworks, industry-specific rules. These are unique to your project but shared across all AI tools.

## How to Use This

### Starting a New Project

1. Clone this repo: `git clone https://github.com/safqore/agent-q-framework.git my-project-name`
2. Reset git: `cd my-project-name && rm -rf .git && git init`
3. Copy `.env.example` to `.env` and add your API keys
4. Start your AI tool and describe your project — it fills in the config and `todo.md` for you
5. Follow the Phase 1 and Phase 2 checklists below

### Adding to an Existing Project

1. Clone this repo somewhere temporary: `git clone https://github.com/safqore/agent-q-framework.git /tmp/agent-q`
2. Copy the framework files into your project:
   ```bash
   cp /tmp/agent-q/CLAUDE.md /tmp/agent-q/agent.md /tmp/agent-q/todo.md /tmp/agent-q/soul.md your-project/
   cp /tmp/agent-q/CHEATSHEET.md /tmp/agent-q/QUICKSTART.md your-project/
   cp -r /tmp/agent-q/context /tmp/agent-q/shared_context your-project/
   cp -r /tmp/agent-q/workflows /tmp/agent-q/tools /tmp/agent-q/rules your-project/
   mkdir -p your-project/.github && cp /tmp/agent-q/.github/copilot-instructions.md your-project/.github/
   mkdir -p your-project/.agent/rules && cp /tmp/agent-q/.agent/rules/agent-q.md your-project/.agent/rules/
   cp /tmp/agent-q/.env.example your-project/
   ```
3. Copy `.env.example` to `.env` and add your API keys
4. Start your AI tool and tell it: "This is an existing project. Read the codebase and fill in the config and todo.md based on what already exists."
5. Use Phase 2B (Code Review) to review your existing code, or Phase 2A to plan new features

### Folder Structure

```
your-project/
├── CLAUDE.md              ← Claude Code config (thin pointer)
├── agent.md               ← OpenAI Codex config (thin pointer)
├── .github/
│   └── copilot-instructions.md ← GitHub Copilot config (thin pointer)
├── .agent/
│   └── rules/
│       └── agent-q.md     ← Google Antigravity config (thin pointer)
├── .claude/
│   └── settings.json      ← Claude Code hooks & statusline config
├── context/               ← Framework rules & preferences (shared by all tools)
│   ├── rules.md           ← Engineering rules, deviation rules, atomic commits
│   ├── planning-protocol.md ← 8-question interview, context budget, discovery levels
│   ├── engineering-preferences.md ← DRY, testing, edge cases, etc.
│   └── frontend.md        ← Frontend development rules (delete for backend-only)
├── shared_context/        ← Project-specific domain knowledge
│   └── README.md          ← Instructions for what to put here
├── agents/                ← Subagent role definitions
│   ├── q-planner.md       ← Creates build plans with task breakdown
│   ├── q-executor.md      ← Executes build plans atomically
│   ├── q-verifier.md      ← Verifies goal achievement, not just task completion
│   └── q-debugger.md      ← Scientific method debugging
├── hooks/                 ← Claude Code hooks (symlinked to projects)
│   ├── agentq-statusline.js  ← Context window progress bar in status line
│   └── agentq-context-monitor.js ← Warns when context is running low
├── commands/              ← Slash commands (symlinked to projects)
│   └── q/
│       ├── plan.md        ← /q:plan — Reverse elicitation planning
│       ├── execute.md     ← /q:execute — Build from plan with deviation rules
│       ├── verify.md      ← /q:verify — Verify work against plan
│       ├── review.md      ← /q:review — 4-section code review
│       ├── progress.md    ← /q:progress — Show project state
│       ├── debug.md       ← /q:debug — Scientific method debugging
│       ├── quick.md       ← /q:quick — Small fix without planning
│       ├── pause.md       ← /q:pause — Save session state
│       └── resume.md      ← /q:resume — Resume from paused session
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
│   ├── spin-jit-su-workflow.md ← Parallel execution (tmux + subagent spawning)
│   ├── pause.md           ← Session pause workflow
│   ├── resume.md          ← Session resume workflow
│   ├── debug.md           ← Scientific method debugging workflow
│   └── project-setup.md   ← Structured project onboarding interview
├── tools/                 ← Executable scripts
│   ├── verify.sh          ← Boolean pass/fail checks on output files
│   ├── spin-jit-su.sh     ← One-command parallel launcher (tmux)
│   └── heartbeat.sh       ← Proactive monitoring (optional, cron-friendly)
├── rules/                 ← Engineering rules for code generation
│   └── _TEMPLATE.md       ← Copy this for every new rule
├── clients/               ← Per-client data (if applicable)
└── templates/             ← Reusable templates for docs/trackers
```

### Phase 1 Checklist (Setup)

- [ ] Clone this repo and rename folder (or copy framework files into existing project)
- [ ] Copy `.env.example` to `.env` and add your API keys
- [ ] Start your AI tool and describe your project — it fills in config and todo.md
- [ ] Create your first workflow file in /workflows
- [ ] Verify: ask the AI to read context/ and describe its role

### Phase 2 Checklist (Planning)

- [ ] Start your AI tool
- [ ] Enter planning mode (Shift+Tab in Claude Code, or just instruct the agent)
- [ ] Paste the Reverse Elicitation Prompt (see below)
- [ ] Answer all of the AI's questions
- [ ] Tell it to write the plan file to `workflows/build-plan-{feature-name}.md`
- [ ] Review the plan
- [ ] Edit anything you disagree with
- [ ] Exit planning mode and tell it to execute the plan

### The Reverse Elicitation Prompt (Copy-Paste This Every Time)

```
Read all files in context/ and workflows/.

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

### Phase 3: Execution (Spin Jit Su Method)

Once the plan is approved:
- Tab 1: Builder agent (auto-accept mode)
- Tab 2: Verifier agent or test runner
- Use context clearing often to keep context clean
- 2-Strike Rule: If you correct the AI twice on the same thing,
  kill the session and restart fresh

### Phase 4: Verification & Deployment

- Visual check: Verify UI in browser
- Logic check: Post-write hooks run tests automatically
- Deploy: Push to Modal, Railway, or Render
- Security: Always run a security audit before deploying
