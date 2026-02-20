# QUICKSTART — Up and Running in 5 Minutes

## Step 1: Clone and rename (30 seconds)

```bash
git clone https://github.com/safqore/agent-q-framework.git my-project-name
cd my-project-name
rm -rf .git
git init
```

## Step 2: Tell Claude about your project (2 minutes)

```bash
claude
```

Describe your project in 2-3 sentences and tell Claude to fill in
CLAUDE.md and todo.md. Claude will set up the role, project context,
folder structure, and first goal for you.

## Step 3: Add secrets (30 seconds)

```bash
cp .env.example .env
```

Open .env and add your real API keys.

## Step 4: Create your first workflow (1 minute)

```bash
cp workflows/_TEMPLATE.md workflows/my-first-task.md
```

Open it and fill in what Claude should do.

## Step 5: Run Phase 2 Planning (start here every time)

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

## Step 6: Verify setup

Ask Claude:
```
What is your role? What workflows do you have?
What is the current project state in todo.md?
```
If it answers all three correctly, you're ready to build.

## Done.

See CHEATSHEET.md for all commands and prompts.
See README.md for the full framework explanation.
