# Build Plan: Agent Skills Spec Adoption

## Goal
Adopt 3 patterns from obsidian-skills into Agent Q:
1. **SKILL.md format** — Define Agent Q as a discoverable skill following the Agent Skills spec
2. **Activation triggers** — Add trigger keywords/file patterns to commands and agents
3. **Plugin packaging** — Add `.claude-plugin/` for marketplace distribution

## Decisions
1. SKILL.md goes at repo root (standard discovery location)
2. No `skills/` subdirectory — existing `agents/`, `workflows/`, `context/` already serve as references
3. Only use spec-standard frontmatter fields to avoid breaking Claude Code command parsing
4. Agents get YAML frontmatter with role, triggers, and capabilities
5. Commands get `triggers:` field added to existing frontmatter
6. No new dependencies — pure markdown and JSON
7. Discovery level: 1 (quick verify)

## Task 1: Skill Definition + Plugin Packaging

**Create SKILL.md** at repo root:
- Follow Agent Skills spec structure
- Define Agent Q's purpose, capabilities, activation triggers
- Reference existing files (agents/, workflows/, context/) as the skill's resources
- Include installation instructions for each platform (Claude Code, Codex CLI, OpenCode)

**Create `.claude-plugin/plugin.json`:**
- Plugin metadata: name, version, author, description, keywords
- Point to SKILL.md as the main skill file

**Create `.claude-plugin/marketplace.json`:**
- Marketplace registration info
- Package name, owner, source

**Update README.md:**
- Add "Installation via Agent Skills" section
- Document marketplace install, npx install, and manual install paths

### Files
- Create: `SKILL.md`
- Create: `.claude-plugin/plugin.json`
- Create: `.claude-plugin/marketplace.json`
- Modify: `README.md`

## Task 2: Activation Triggers + Agent Metadata

**Update agents/*.md** — Add YAML frontmatter to each agent file:
```yaml
---
name: q-planner
role: planning
triggers: [plan, interview, feature, scope, build plan]
capabilities: [reverse elicitation, task breakdown, discovery assessment]
---
```

**Update .claude/commands/q/*.md** — Add `triggers:` to existing frontmatter:
```yaml
triggers: [keyword1, keyword2]
```

**Update CLAUDE.md** — Add reference to SKILL.md in the context loading section.

### Files
- Modify: `agents/q-planner.md`
- Modify: `agents/q-executor.md`
- Modify: `agents/q-verifier.md`
- Modify: `agents/q-debugger.md`
- Modify: `.claude/commands/q/*.md` (12 files)
- Modify: `CLAUDE.md`

## Edge Cases
- SKILL.md at root could conflict if user installs Agent Q into a project that has its own SKILL.md — mitigated by clear namespacing in the skill name
- Non-standard frontmatter fields in commands — only add `triggers:` which is a simple list, unlikely to break parsers
- Plugin.json schema may evolve — keep minimal, pin to current spec

## Verification
1. Run `/q:status` to confirm all commands still discoverable after frontmatter changes
2. Validate plugin.json and marketplace.json are valid JSON (`node -e "JSON.parse(...)"`)
3. Verify SKILL.md follows the Agent Skills spec structure
4. Verify agents still load correctly (read each file, check frontmatter parses)

## Rollback
`git revert <commit>` — all changes are additive. Delete SKILL.md and .claude-plugin/, revert frontmatter additions.
