---
name: q:status
description: Show all available /q: commands with descriptions
triggers: [status, commands, list, help, available]
argument-hint: ""
allowed-tools: [Read, Glob]
---

## Objective
Display a formatted list of all available `/q:` slash commands with a one-line
description for each.

## Process

1. **Discover commands.** Glob for all `.claude/commands/q/*.md` files.

2. **Extract info.** Read the first 5 lines of each file to get:
   - The command name from the `name:` frontmatter field (or derive from filename)
   - The description from the `description:` frontmatter field (or from the `## Objective` line)

3. **Present results.** Display a formatted table:

   ```
   /q:command    — one-line description
   ```

   Sort alphabetically by command name. Exclude `/q:status` itself.

## Success Criteria
- All `/q:` commands listed
- Each has a one-line description
- Output is clean and scannable
