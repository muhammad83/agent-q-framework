---
plan: superpowers-platform
status: pending
stream: C
parallel: true
discovery: 1
---

# Build Plan — Superpowers Platform & Composability Integration

Add multi-platform support (Cursor, Codex, OpenCode, Gemini CLI) and deepen agentskills.io skill composability spec.

## Decisions

- Platform configs are install-time files, zero runtime context cost
- Session-start hook detects platform and injects appropriate context
- Single source of truth is `SKILL.md` — platform configs derive from it
- Deeper agentskills.io adoption enables community-contributed skills
- Each platform follows its native discovery mechanism (no shims)

## Task 1 — Multi-Platform Support

**Create:** `hooks/session-start.sh`
- Detects which platform is running (Claude Code, Cursor, Codex, OpenCode, Gemini CLI)
- Detection method: check environment variables and process names
  - `CLAUDE_CODE` env var → Claude Code
  - `CURSOR_SESSION` or cursor process → Cursor
  - `CODEX_SESSION` or codex process → Codex
  - `OPENCODE_SESSION` → OpenCode
  - `GEMINI_CLI` → Gemini CLI
- Outputs platform-appropriate context injection format
- Falls back to Claude Code format if platform unknown

**Create:** `.cursor-plugin/plugin.json`
- Plugin metadata for Cursor marketplace
- Maps Agent Q skills to Cursor's skill discovery format
- References `SKILL.md` for capability declarations
- Includes activation triggers (file patterns, keyword triggers)

**Create:** `.codex/setup.md`
- Installation instructions for Codex
- Symlink-based skill discovery (Codex native pattern)
- Maps `/q:` commands to Codex command format
- Includes verification steps

**Create:** `.opencode/config.json`
- Hook auto-registration for OpenCode
- Maps Agent Q workflows to OpenCode's hook system
- Session-start context injection

**Create:** `agents/gemini-cli-extension.md`
- Tool mapping for Gemini CLI native extension format
- Maps Agent Q capabilities to Gemini's tool declarations
- Handles platform limitations (no subagent support → falls back to inline execution per Superpowers pattern)

**Modify:** `CLAUDE.md`
- Add on-demand loading entries for all new files:
  - `hooks/session-start.sh` — when configuring platform hooks
  - `workflows/tdd.md` — when doing TDD
  - `workflows/finish-branch.md` — when completing a branch
  - Platform configs — when setting up for a new platform

**Verify:** Validate each config file structure against platform documentation. Confirm `hooks/session-start.sh` correctly detects platform (test with env var overrides). Confirm CLAUDE.md entries point to files that exist.

## Task 2 — Skill Composability (agentskills.io Deepening)

**Modify:** `SKILL.md`
- Add composability metadata:
  - `provides:` — list of capabilities this skill offers (planning, tdd, debugging, verification, etc.)
  - `requires:` — list of dependencies (Node.js, git, etc.)
  - `extends:` — list of skills this builds on (if any)
  - `triggers:` — file patterns and keywords that activate specific sub-skills
- Add contribution format:
  - How to add a new skill to Agent Q
  - Required file structure (workflow + command + optional agent)
  - Naming conventions (`/q:{name}`, `workflows/{name}.md`)
  - Testing requirements (manual verification checklist)
- Add skill discovery section:
  - How platforms find and load Agent Q skills
  - Hook registration patterns per platform
  - Activation trigger format

**Modify:** `.claude-plugin/plugin.json`
- Update capability declarations to include new features (TDD, brainstorm, finish, two-stage review)
- Add composability fields matching SKILL.md metadata
- Update version number

**Create:** `CONTRIBUTING.md`
- How to contribute a new skill to Agent Q
- Skill template with required sections
- Review process (use `/q:review` on the skill itself)
- Testing checklist

**Verify:** Validate `SKILL.md` against agentskills.io spec. Confirm a hypothetical new skill can be added following the contribution format. Confirm `.claude-plugin/plugin.json` is valid JSON with updated capabilities.

## Edge Cases

- Platform detection false positive: hook checks multiple signals before confirming platform
- Unknown platform: falls back to Claude Code format (most capable, safest default)
- Gemini CLI no-subagent limitation: document that `/q:orchestrate` and `/q:spinjitsu` fall back to inline execution
- CONTRIBUTING.md scope: contribution format only — not a full open-source governance doc

## Rollback

- Task 1: delete `hooks/session-start.sh`, `.cursor-plugin/`, `.codex/`, `.opencode/`, `agents/gemini-cli-extension.md`, revert CLAUDE.md changes
- Task 2: `git revert` SKILL.md and plugin.json commits, delete CONTRIBUTING.md
- Platform configs are inert unless actively used — removing them has zero side effects
