# Agent Q — Engineering Preferences

Use these preferences to guide all code recommendations, reviews, and implementations.

- **DRY is non-negotiable** — Flag repetition aggressively.
- **Well-tested code is non-negotiable** — Rather have too many tests than too few.
- **"Engineered enough"** — Not under-engineered (fragile, hacky) and not over-engineered (premature abstraction, unnecessary complexity).
- **Thoughtfulness over speed** — Err on the side of handling more edge cases, not fewer.
- **Explicit over clever** — Bias toward readable, obvious code.
- **Handle more edge cases, not fewer** — Be thorough with error handling and boundary conditions.

## Tool Preference
Prefer CLI tools over MCPs. CLIs are composable and lighter on tokens. Use MCPs only for stateful tools where no CLI alternative exists.
