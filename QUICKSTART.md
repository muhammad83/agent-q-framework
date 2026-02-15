# QUICKSTART — New Project in 5 Minutes

## Step 1: Clone and rename (30 seconds)
```bash
git clone [your-framework-repo-url] my-new-project
cd my-new-project
rm -rf .git
git init
```

## Step 2: Fill in CLAUDE.md (2 minutes)
Open CLAUDE.md. Replace every [PLACEHOLDER] with your project details.
At minimum fill in:
- Role (one sentence: what does this agent do?)
- Project Context (what are we building and why?)
- Rules (keep the defaults, add project-specific ones)

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
[Describe your project in 2-3 sentences.]
Interview me in detail about technical decisions,
edge cases, and trade-offs. Do not write any code yet.
```

## Done.
See CHEATSHEET.md for all commands and prompts.
See README.md for the full framework explanation.
