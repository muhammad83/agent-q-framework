# QUICKSTART — New Project in 5 Minutes

## Step 1: Clone and rename (30 seconds)

```bash
git clone https://github.com/safqore/agent-q-framework.git my-project-name
cd my-project-name
rm -rf .git
git init
```

## Step 2: Fill in CLAUDE.md (2 minutes)

Open CLAUDE.md and fill in the project-specific sections. Claude will
manage the operational rules — you just provide the context.
At minimum fill in:

- Role (one sentence: what does this agent do?)
- Project Context (what are we building and why?)
- Folder Structure (update to match your project)

## Step 3: Fill in todo.md (30 seconds)

Open todo.md. Set:

- Project name
- Current Goal (what's the first thing to build?)

## Step 4: Add secrets (30 seconds)

```bash
cp .env.example .env
```

Open .env and add your real API keys.

## Step 5: Create your first workflow (1 minute)

```bash
cp workflows/_TEMPLATE.md workflows/my-first-task.md
```

Open it and fill in what Claude should do.

## Step 6: Run Phase 2 Planning (start here every time)

```bash
claude
```

Press Shift+Tab (Plan Mode), then paste:

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
before writing the plan. Save the plan as
workflows/build-plan-{feature-name}.md.
```

## Done.

See CHEATSHEET.md for all commands and prompts.
See README.md for the full framework explanation.
