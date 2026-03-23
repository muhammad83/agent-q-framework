# Contributing to Agent Q

This guide covers how to contribute a new skill to the Agent Q framework.

## What is a Skill?

A skill is a self-contained capability that Agent Q can invoke via a slash command. Examples: planning (`/q:plan`), debugging (`/q:debug`), code review (`/q:review`).

Each skill consists of a workflow definition, a command entry point, and optionally a subagent role definition and/or an executable script.

## Skill Template

### 1. Create the Workflow File

Create `workflows/{name}.md` with the following structure:

```markdown
---
name: {name}
description: One-line description of what this skill does
autonomy: auto | confirm
namespace: planning | execution | quality | dx
triggers:
  keywords: [list, of, activation, keywords]
  files: [optional, file, patterns]
---

# Workflow: {Name}

## When to Use
Describe when this workflow should be invoked.

## Steps
1. Step one
2. Step two
3. Step three

## Inputs
- What the skill needs to start

## Outputs
- What the skill produces when complete

## Edge Cases
- Known limitations or special handling
```

### 2. Create the Command File

Create `.claude/commands/q/{name}.md`:

```markdown
You are a Q-{Role} agent. Your job is to {one-line description}.

## Context Loading
Before starting, read these files:
- `context/rules.md`
- `workflows/{name}.md`
- `todo.md`

## Execution
{Instructions for how the agent should execute this skill}
```

### 3. (Optional) Create a Subagent Role

If the skill needs its own agent identity, create `agents/q-{name}.md`:

```markdown
---
name: q-{name}
role: {role}
triggers: [{trigger keywords}]
capabilities: [{list of capabilities}]
---

# Agent Role: Q-{Name}

## Identity
{Description of what this agent does}

## Core Responsibilities
1. {Responsibility 1}
2. {Responsibility 2}

## What You Do
- {Behavior 1}
- {Behavior 2}

## What You Don't Do
- {Anti-pattern 1}
- {Anti-pattern 2}
```

### 4. (Optional) Create a Tool Script

If the skill needs automation, create `tools/{name}.sh`:

```bash
#!/usr/bin/env bash
# tools/{name}.sh -- {description}
set -euo pipefail

# Script implementation
```

## Naming Conventions

| Item | Pattern | Example |
|------|---------|---------|
| Command | `/q:{name}` | `/q:tdd` |
| Workflow | `workflows/{name}.md` | `workflows/tdd.md` |
| Agent | `agents/q-{name}.md` | `agents/q-tdd.md` |
| Tool | `tools/{name}.sh` | `tools/tdd.sh` |

Names must be lowercase, use hyphens for multi-word names (e.g., `code-review`, not `code_review`).

## Registration Checklist

After creating the skill files:

1. Add the command to the Commands table in `SKILL.md`
2. Add the workflow to the on-demand loading section in `CLAUDE.md`
3. Update the folder structure in `README.md` if new directories were created
4. If the skill adds a new capability, add it to the `provides` list in:
   - `SKILL.md` frontmatter
   - `.claude-plugin/plugin.json`
   - `.cursor-plugin/plugin.json`

## Testing Checklist

Before submitting a pull request:

- [ ] Run the skill end-to-end on a test project
- [ ] Verify the command appears in `/q:status` output
- [ ] Verify the skill loads on demand (check that `CLAUDE.md` has the on-demand entry)
- [ ] Verify the skill updates `todo.md` when it completes work
- [ ] Run `/q:review` on the skill files themselves
- [ ] Verify the skill does not break existing commands (run `/q:status`)
- [ ] Check that the workflow file has valid YAML frontmatter
- [ ] Check that naming conventions are followed

## Review Process

1. Open a pull request with the new skill files
2. The reviewer will run `/q:review` on the PR to check quality
3. The reviewer will test the skill manually on a sample project
4. Once approved, the skill is merged and available to all Agent Q users

## Scope

This document covers contributing skills only. For framework-level changes (new deviation rules, new agent types, architectural changes), open an issue first to discuss the design.
