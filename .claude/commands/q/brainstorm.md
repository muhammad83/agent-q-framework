---
name: q:brainstorm
description: Visual brainstorming companion with live browser preview
triggers: [brainstorm, explore, ideate, whiteboard, visual]
argument-hint: "[topic or feature to brainstorm]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch]
autonomy: confirm
namespace: planning
---

## Objective
Conduct a divergent exploration session with a live visual companion in the browser.
The agent sends mockups, diagrams, and markdown to a local WebSocket server that renders
them in real-time.

## Execution Context
- Read `context/planning-protocol.md` for planning foundations
- Read `context/engineering-preferences.md` for coding standards
- Read `todo.md` for current project state

## Process

1. **Start the visual brainstorm server.**
   ```bash
   node tools/visual-brainstorm.cjs &
   BRAINSTORM_PID=$!
   ```
   If the port is already in use, suggest an alternative port:
   ```bash
   AGENTQ_BRAINSTORM_PORT=3848 node tools/visual-brainstorm.cjs &
   BRAINSTORM_PID=$!
   ```
   If running headless or via SSH (no browser available), skip the server
   and fall back to terminal-only mode. Inform the user:
   "No browser available -- running in terminal-only mode."

2. **Open browser.** Direct user to `http://127.0.0.1:3847` (or the configured port).
   Use `/chrome` if available, or instruct the user to open the URL manually.

3. **Conduct divergent exploration.** For the given topic:
   a. Ask clarifying questions **one at a time** -- do not batch questions
   b. Explore 2-3 different approaches with trade-offs for each
   c. For each question/topic, decide whether to respond visually or in terminal:
      - **Visual** (mockups, diagrams, architecture): send to browser via stdin JSON
      - **Terminal** (text explanations, trade-off lists): respond in the conversation
   d. Present design decisions in digestible sections, not all at once

4. **Send visual content to the browser.** Write JSON to the server's stdin:
   - Mockups: `echo '{"type":"mockup","content":"<svg>...</svg>"}' > /proc/$BRAINSTORM_PID/fd/0`
   - Markdown: `echo '{"type":"markdown","content":"# Title\n\nContent..."}' > /proc/$BRAINSTORM_PID/fd/0`
   - Diagrams: `echo '{"type":"diagram","content":"<svg>...</svg>"}' > /proc/$BRAINSTORM_PID/fd/0`

   On macOS, use a named pipe or write via the process fd directly. The server
   reads newline-delimited JSON from stdin.

5. **Converge on a spec.** Once exploration is complete:
   a. Summarize all decisions made
   b. Get user confirmation
   c. Write the spec document to `docs/specs/{feature-name}.md`
   d. Update `todo.md` with the spec reference

6. **Shut down server.**
   ```bash
   kill $BRAINSTORM_PID 2>/dev/null
   ```
   The server also auto-terminates after 30 min idle.

## Visual Content Guidelines
- **Mockups:** Use inline SVG with simple shapes (rect, text, line) for wireframes
- **Diagrams:** Use inline SVG for architecture/flow diagrams (boxes + arrows)
- **Markdown:** Use standard markdown for specs, trade-off tables, and decision records

## Edge Cases
- Port already in use: detect the error and suggest `AGENTQ_BRAINSTORM_PORT=3848`
- No browser (headless/SSH): fall back to terminal-only, skip server startup
- Server crashes mid-session: inform user, continue in terminal-only mode
- User exits early: save partial exploration to `docs/specs/` if any decisions were made

## Success Criteria
- Brainstorm session explored at least 2 different approaches
- Visual content sent to browser for visual topics (when browser available)
- Spec document written to `docs/specs/{feature-name}.md`
- Server shut down cleanly on completion
- `todo.md` updated with spec reference
