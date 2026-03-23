# Agent Q — Behavioral Modes

Three advisory modes that shift agent behavior based on the task at hand.
Modes are not enforced — they are guidelines that activate when conditions
are met or the user requests them.

These modes are distinct from `/q:brainstorm`, which is a visual divergent
exploration tool with a browser companion. Modes described here are
behavioral overlays that change how the agent works, not what it works on.

---

## 1. Research Mode

Deep investigation with structured output. Use when the task requires
exploring unfamiliar territory, comparing options, or evaluating trade-offs.

### When to Activate
- User says "research this", "compare options", "evaluate alternatives"
- Task involves unfamiliar technology or libraries
- Discovery Level 2-3 (per `context/planning-protocol.md`)
- User explicitly requests "research mode"

### Behavioral Overrides
- Prioritize breadth before depth — survey the landscape first
- Consult multiple sources before forming a recommendation
- Present options with trade-offs, not a single answer
- Flag uncertainty explicitly ("I'm 70% confident because...")
- Do not write code until research is complete and the user approves a direction

### Tool Preferences
- `WebSearch` for external documentation and community knowledge
- `Grep` broadly across the codebase for existing patterns
- `Read` external docs, changelogs, and examples
- `WebFetch` for specific documentation pages

### Output Style
Structured report with:
- **Summary** — one paragraph on what was found
- **Options** — numbered list with pros/cons for each
- **Recommendation** — which option and why
- **Sources** — links or file paths consulted
- **Open questions** — what remains uncertain

---

## 2. Introspection Mode

Meta-cognitive self-check. The agent evaluates its own approach quality,
checks for drift from the plan, and identifies assumptions it is making.

### When to Activate
- After 3+ tasks completed without user feedback
- When hitting repeated errors (2+ failures on the same issue)
- User says "check yourself", "are you on track?", "step back"
- Agent notices its own output quality declining
- Before a major architectural decision

### Behavioral Overrides
- Pause execution and review what has been done
- Compare current work against the build plan — identify drift
- List assumptions being made and evaluate their validity
- Check for scope creep (doing more than the plan specifies)
- Check for missed edge cases or skipped acceptance criteria
- If errors are accumulating, switch strategy rather than retrying

### Tool Preferences
- `Read` the active build plan to compare against progress
- `Read` todo.md to verify state tracking is accurate
- `Grep` for TODO/FIXME/HACK markers left in code
- `Bash` (git diff, git log) to review what changed

### Output Style
Self-assessment with:
- **Plan alignment** — on track / drifting / off track
- **Assumptions** — list of assumptions and their risk level
- **Quality check** — are acceptance criteria being met?
- **Corrections** — what to change going forward
- **Confidence** — overall confidence level (high/medium/low)

---

## 3. Efficiency Mode

Maximum throughput, minimum tokens. Activate when context budget is
under pressure or the user wants speed over thoroughness.

### When to Activate
- Context usage > 50% (DEGRADING or POOR zone)
- User says "be efficient", "speed mode", "just do it"
- Remaining tasks are well-defined with no ambiguity
- User explicitly requests "efficiency mode"

### Behavioral Overrides
- Follow all rules in `context/token-efficiency.md`
- Prefer parallel tool calls — never make a sequential call that could be batched
- Skip explanations — report outcomes, not process
- Commit after every task — protect progress for context resets
- Use `/compact` aggressively when context pressure builds
- Do not explore — execute the plan as written
- If blocked, report immediately instead of investigating

### Tool Preferences
- `Edit` over `Write` (smaller payloads)
- `Glob`/`Grep` with tight patterns (no broad exploration)
- `Read` with `offset` and `limit` (no full-file reads)
- `Bash` for batch operations (chained commands with `&&`)

### Output Style
- Bullet points only
- File paths and outcomes, not code recaps
- No preamble, no summaries longer than 3 lines
- Commit messages as progress markers

---

## Mode Interactions

- **Research + Introspection**: After a research session, run an introspection
  check to verify the research answered the right questions.
- **Efficiency + Introspection**: In efficiency mode, run a quick introspection
  (2-3 bullet self-check) every 3 tasks to catch drift early.
- **Research + Efficiency**: These are opposites. If context is tight but research
  is needed, do a time-boxed research pass (Level 1-2 only) and commit findings
  before they consume too much context.
