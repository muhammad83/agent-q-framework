# CLAUDE.md — [PROJECT NAME]

## Role
You are [DESCRIBE THE AGENT'S ROLE IN ONE SENTENCE].
You follow the Agent Q framework:
- Read Workflows in /workflows for your instructions.
- Execute Tools in /tools for actions.
- Track all state in todo.md.

## Rules
1. Before starting any task, read todo.md for current project state.
2. After completing any task, update todo.md with what was done.
3. Never edit CLAUDE.md manually. If I correct a behavior during a
   session, update this file yourself to prevent recurrence.
4. Keep all workflow instructions in /workflows as .md files.
5. Keep all executable scripts in /tools.
6. Never store secrets in code. Use .env files.
7. When unsure about a decision, ask — don't guess.

## Project Context
[DESCRIBE WHAT THIS PROJECT DOES IN 2-3 PARAGRAPHS. INCLUDE:
- What problem it solves
- Who uses it
- What the key features are]

## Analysis Frameworks
[DELETE THIS SECTION IF NOT APPLICABLE. OTHERWISE REPLACE WITH
YOUR PROJECT'S DOMAIN EXPERTISE. EXAMPLES:]

### Framework 1: [NAME]
- [Key question this framework answers]
- [Key question this framework answers]
- [Key question this framework answers]

### Framework 2: [NAME]
- [Key question this framework answers]
- [Key question this framework answers]
- [Key question this framework answers]

## Folder Structure
[UPDATE THIS TO MATCH YOUR ACTUAL STRUCTURE]
```
your-project/
├── CLAUDE.md
├── todo.md
├── .env
├── workflows/
├── tools/
└── [any project-specific folders]
```

## Hooks
[ADD AUTO-RUN COMMANDS HERE. DELETE IF NOT NEEDED YET.]
- After writing any .py file, run: ruff check <filename>
- After writing any .js file, run: npm run lint

## Style
- [HOW SHOULD CLAUDE WRITE CODE? e.g. "Simple over clever"]
- [HOW SHOULD CLAUDE COMMUNICATE? e.g. "Direct and specific"]
- [ANY LIBRARIES TO PREFER OR AVOID?]
