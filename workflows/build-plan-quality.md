# Build Plan B: Quality — Token Optimization, Language Rules, Security Scanning

## Goal
Reduce context waste, add language-specific coding rules for TypeScript and Python, and add a secrets detection hook to catch leaked credentials before commit.

## Discovery Level
Level 1 — Quick verify.

## Tasks

### Task 1: Token optimization + language rules
- Modify `~/.claude/settings.json` — add autocompact override and thinking token limit:
  ```json
  "env": {
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50",
    "MAX_THINKING_TOKENS": "10000"
  }
  ```
- Create `context/rules-typescript.md` — TypeScript/React/Next.js/Node.js rules:
  - Strict types (no `any`)
  - React: functional components, hooks rules, proper key props
  - Next.js: App Router patterns, server vs client components
  - Node: async/await over callbacks, proper error handling
  - TailwindCSS: utility-first, no inline styles
- Create `context/rules-python.md` — Python rules:
  - Type hints on all function signatures
  - f-strings over .format()
  - Pydantic for data validation
  - async def for I/O-bound operations
- Modify `context/rules.md` — add note: "Load `context/rules-typescript.md` or `context/rules-python.md` based on project language"

### Task 2: Security scanning hook
- Create `tools/security-scan.cjs` — Node.js script that scans staged files for:
  - API keys (sk-*, AKIA*, etc.)
  - Private keys (BEGIN RSA/EC/OPENSSH)
  - Connection strings with passwords
  - .env file contents committed directly
  - JWT secrets, Stripe keys, AWS credentials
  - Returns exit 1 with findings if detected
- Add as a PreToolUse hook in `~/.claude/settings.json` (triggers before Write/Edit)

### Task 3: Update todo.md

## Files
| Action | File |
|---|---|
| Modify | `~/.claude/settings.json` |
| Create | `context/rules-typescript.md` |
| Create | `context/rules-python.md` |
| Modify | `context/rules.md` |
| Create | `tools/security-scan.cjs` |
| Modify | `todo.md` |

## Edge Cases
- False positives on test fixtures containing fake keys → allow `test/` and `__test__/` directories
- Autocompact at 50% may be too aggressive for long sessions → user can override

## Verification
- Create a test file with a fake AWS key, verify security scan catches it
- Check `/context` shows reduced token usage after optimization

## Rollback
New files + settings changes. Revert settings.json and delete new files.
