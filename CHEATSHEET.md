# Agent Q Framework — Prompts & Commands Cheat Sheet

Keep this open during every session. These are the exact commands
and prompts you use at each phase.

---

## SLASH COMMANDS (QUICK REFERENCE)

These replace copy-paste prompts. Use them directly in Claude Code:

| Command | What It Does | When to Use |
|---------|-------------|-------------|
| `/q:plan` | Reverse elicitation planning interview | Starting a new feature |
| `/q:execute` | Build from plan with deviation rules | After plan is approved |
| `/q:verify` | Verify work against plan + code review | After build is complete |
| `/q:review` | 4-section code review | Reviewing existing or new code |
| `/q:progress` | Show project state + next action | Start of session, checking status |
| `/q:debug` | Scientific method debugging | Bug found, tests failing |
| `/q:quick` | Small fix, no planning overhead | Typos, 1-2 file fixes |
| `/q:pause` | Save state for next session | Ending a session mid-task |
| `/q:resume` | Pick up where you left off | Starting a new session |

**Quick workflow:** `/q:plan` → `/q:execute` → `/q:verify`

**Session flow:** `/q:resume` → (work) → `/q:pause`

---

## CONTEXT MONITOR

Agent Q includes automatic context window monitoring:

- **Status line** shows a colored progress bar: green (PEAK) → yellow (GOOD/DEGRADING) → red (POOR)
- **Warnings** inject at 35% remaining (WARNING) and 25% remaining (CRITICAL)
- When you see DEGRADING: wrap up current task and commit
- When you see POOR: `/compact` or `/clear` immediately

Context budget targets (from planning protocol):
- 0-30% used = PEAK (do your best work)
- 30-50% = GOOD (finish current task set)
- 50-70% = DEGRADING (wrap up and commit)
- 70%+ = POOR (stop, commit, `/compact` or `/clear`)

---

## VOICE PROMPTING (SPEED MULTIPLIER)

Dictate your prompts instead of typing. You'll move 3-5x faster.
Only type for terminal commands.

**macOS (free, built-in):**
Press 🌐 (Globe key) twice or Fn twice to toggle dictation.
Works in any text field including terminal input.

**SuperWhisper (recommended, macOS):**
Always-on, faster than Apple dictation, better accuracy.
https://superwhisper.com

**Whisper (free, cross-platform):**
OpenAI's speech-to-text model. Run locally or via API.
https://github.com/openai/whisper

**Tips:**
- Use a walkie-talkie style: hold button → speak → release
- Speak in full sentences, not keywords
- Say punctuation: "comma" "period" "new line"
- Lost your voice? You're doing it right. Take breaks.

---

## PHASE 1: SETUP

### New Project
```bash
git clone https://github.com/muhammad83/agent-q-framework.git my-project-name
cd my-project-name
rm -rf .git
git init
cp .env.example .env   # add your real API keys
```

### Existing Project
```bash
# Copy framework files into your project
git clone https://github.com/muhammad83/agent-q-framework.git /tmp/agent-q
cp /tmp/agent-q/CLAUDE.md /tmp/agent-q/agent.md /tmp/agent-q/todo.md /tmp/agent-q/soul.md your-project/
cp /tmp/agent-q/CHEATSHEET.md /tmp/agent-q/QUICKSTART.md your-project/
cp -r /tmp/agent-q/context /tmp/agent-q/shared_context your-project/
cp -r /tmp/agent-q/workflows /tmp/agent-q/tools /tmp/agent-q/rules your-project/
mkdir -p your-project/.github && cp /tmp/agent-q/.github/copilot-instructions.md your-project/.github/
mkdir -p your-project/.agent/rules && cp /tmp/agent-q/.agent/rules/agent-q.md your-project/.agent/rules/
cp /tmp/agent-q/.env.example your-project/
cd your-project && cp .env.example .env   # add your real API keys
```

### First AI Session
Start your AI tool and describe your project:
```
Read all files in context/ and workflows/.
[Describe your project in 2-3 sentences.]
Fill in the config file and todo.md based on what you see.
```

### Project Setup Interview (Recommended)
Instead of a free-form description, run the structured setup interview:
```
Run the project setup interview from workflows/project-setup.md.
```
This profiles your project with 5 quick questions, shows you every
framework feature with tailored recommendations, and lets you pick
which ones to adopt. Takes ~3 minutes. Prevents the "I wish I'd
included that feature" problem.

### Verification Prompt
```
Read all files in context/ and the project structure.
Tell me:
1. What is your role?
2. What workflows do you have?
3. What is the current project state in todo.md?
```
If it answers all three correctly, Phase 1 is done.

---

## PHASE 2A: PLANNING (GREENFIELD)

Use this when starting a new project from scratch.

### Step 1 — Enter Plan Mode
In Claude Code: Press `Shift+Tab`
In other tools: Instruct the agent to plan without writing code.

### Step 2 — Reverse Elicitation Prompt (copy this every time)
```
Read all files in context/ and workflows/.

[YOUR 2-3 SENTENCE PROJECT DESCRIPTION HERE]

Interview me in detail about technical decisions, implementation
details, edge cases, UI/UX concerns, and trade-offs. Do not write
any code. Just ask me questions until you fully understand what
to build.

For each question:
- Give me your recommended answer and why.
- Then ask if I agree or want something different.
- If I say "you decide" or "not sure", go with your recommendation
  and move on.

After all questions are answered, summarize every decision we made
before writing the plan.
```

### Step 3 — After answering all questions, say:
```
Write a detailed implementation plan based on everything we
discussed. Save it as workflows/build-plan-{feature-name}.md.
Include every decision we made and every edge case we covered.
```

### Step 4 — Review the plan
In Claude Code: Press `Ctrl+G` (opens in editor)
In other tools: Open the plan file and review it.
Read it. Edit anything you disagree with. Save.

### Step 5 — Switch to Code Mode
In Claude Code: Press `Shift+Tab`
In other tools: Instruct the agent to begin implementation.

### Step 6 — Execute
```
Read workflows/build-plan-{feature-name}.md and build everything
exactly as specified in the plan.
```

---

## PHASE 2B: CODE REVIEW (EXISTING CODE)

Use this to review any existing code — either after Phase 3 (build) or
when onboarding a pre-existing codebase.
Full prompt and instructions are in `workflows/code-review.md`.

Engineering preferences for reviews are in `context/engineering-preferences.md`.

### Quick version:
1. Enter planning mode
2. Open and paste the prompt from `workflows/code-review.md`
3. Choose BIG CHANGE (4 issues per section) or SMALL CHANGE (1 per section)
4. Work through: Architecture → Code Quality → Tests → Performance
5. Approve changes, exit planning mode
6. Tell the AI: `Execute all the changes we agreed on in the review.`
```

---

## PHASE 3: EXECUTION (SPIN JIT SU METHOD)

### Terminal Tab 1 — Builder
```bash
# Claude Code:
claude -dangerously-skip-permissions
# Other tools: use their auto-accept/autonomous mode
```
Then:
```
Read workflows/build-plan-{feature-name}.md and execute it fully.
```

### Terminal Tab 2 — Verifier
```bash
# Watch logs in real time
tail -f logs | claude

# Or run tests
claude "Run all tests and report what fails."
```

### Context Hygiene Commands
```
/clear          — Wipe context, start fresh (Claude Code)
/compact        — Summarize and compress current context (Claude Code)
```

### The 2-Strike Rule
If you correct the AI twice on the same mistake:
1. Stop the session (Ctrl+C)
2. Update todo.md with what went wrong
3. Start a new session
4. It reads todo.md and picks up with fresh context

### Conversation Steering (Phase 3)

Don't just paste prompts and hope. Steer the conversation.

**Prevent premature building:**
- "Discuss this first. Don't write code yet."
- "Give me 3 options before you pick one."
- "What are the trade-offs?"

**When agent asks questions it could answer itself:**
- "Read more code to answer your own questions."
- "Check the existing tests before asking me."

**When you're ready to execute:**
- "Build it."
- "Okay, do it."
- "Ship it."

**When agent seems rushed or sloppy:**
- "Take your time."
- "Slow down. Read the full file first."

**When something breaks:**
- Don't revert. Fix forward.
- "That's wrong. Fix it and keep going."
- Commit when the outcome is good, not when every line is perfect.

---

## PHASE 3+: SPIN JIT SU (PARALLEL EXECUTION)

Full workflow: `workflows/spin-jit-su-workflow.md`

**Default to parallel whenever tasks are independent.** Same project, different
features? Parallel. Multiple projects? Parallel. Only go sequential when there's
a hard dependency.

### One-Command Launch
```bash
./tools/spin-jit-su.sh                    # Auto-detect all build plans
./tools/spin-jit-su.sh plan-a.md plan-b.md  # Specific plans
SPINJITSU_MODEL=claude-sonnet-4-6 ./tools/spin-jit-su.sh  # Override model
```

### Model Alias (add to ~/.zshrc)
```bash
alias opusplan="claude --model claude-opus-4-6"
```

### Cost Rule
```
Plan with Opus → Build with Sonnet → Verify with Opus = ~60% savings
```

### Manual Fallback
1. `tmux new-session -s spinjitsu`
2. Open a window per task, start builder in auto-accept mode
3. Kick off each: `Read workflows/build-plan-{feature}.md and execute it fully.`
4. Rotate every 5-10 min — glance, steer, unblock, move on
5. Verify each with `opusplan` when done
6. Merge, clean up, `tmux kill-session -t spinjitsu`

### Scaling
| Streams | Strategy |
|---------|----------|
| 2-4 | `./tools/spin-jit-su.sh` — tmux windows, rotate. |
| 5-8 | Same script. Named windows (`Ctrl+B` + number). |
| 8+ | Cloud sessions with `&` prefix. |

### Mobile
- `& claude` → cloud session, open URL from any device
- Happy Coder app → chat interface to sessions from phone

### If an Instance Goes Off-Track
```
Stop. Read workflows/build-plan-{feature}.md again.
You're off-plan. The current task is: [specific task]. Do only that.
```

---

## POST-BUILD REFACTOR (AFTER PHASE 3, BEFORE PHASE 4)

After every feature or PR merge, ask these four questions:

1. "Now that you built it, what would you have done differently?"
2. "What can we refactor to make this cleaner?"
3. "Do we have enough tests? What's missing?"
4. "Update documentation for what changed."

Why this works: The agent discovers pain points during building,
just like humans do. Ask afterwards because that's when it knows
where things didn't work on the first try.

Don't skip this. The 10 minutes here save hours of tech debt later.

---

## PHASE 4: VERIFICATION & DEPLOYMENT

### Visual Verification
```
Open the app in a browser and test every button. Take a
screenshot of each page and tell me if anything looks wrong.
```

### Security Audit (run before every deployment)
```
Scan all files in /tools for:
1. Hardcoded API keys or secrets
2. SQL injection vulnerabilities
3. Missing input validation
4. Exposed endpoints without authentication
Report everything you find.
```

### Deploy to Modal
```
Push tools/server.py to Modal to run as a serverless function.
Set it to run on every incoming webhook.
```

### Deploy to Railway/Render
```
Create a Procfile and requirements.txt for deploying
tools/server.py to Railway.
```

---

## VERIFICATION SCRIPT

The verify script runs boolean pass/fail checks on any output file.

### Customize checks
Open `tools/verify.sh` and edit the CHECKS array.
Each check is a label and a grep pattern: `"Label:::pattern"`

### Run it
```bash
./tools/verify.sh path/to/output.md
```

### Example checks for a sales call analysis
```
"Has Value Equation section:::## Value Equation\|value equation"
"Has emotional state identified:::emotional state\|State:"
"Has upfront contract:::upfront contract\|next steps"
"Has specific next action:::Action:\|- \[ \]"
"Has objections listed:::objection\|pushback\|concern"
```

---

## EMERGENCY COMMANDS

### AI is stuck or looping
```
/clear
Read todo.md. What is the current state? What should we do next?
```

### AI made a mess of the files
```
git diff                    — See what changed
git checkout -- .           — Undo all changes
git stash                   — Save changes but revert
```

### AI broke something that was working
```
git log --oneline -10       — Find the last good commit
git checkout [commit-hash]  — Go back to it
```

---

## SESSION START / END (PAUSE & RESUME)

### Starting a Session
```
/q:resume
```
Or the manual way:
```
Read all files in context/ and todo.md.
What is the current project state? What should we work on next?
Do not make any changes yet — just tell me your understanding.
```

### Ending a Session
```
/q:pause
```
Or the manual way:
```
Update todo.md with:
1. Everything we accomplished this session
2. What we should do next session
3. Any known issues or blockers
4. Any decisions we made and why
```

The `/q:pause` command also creates `.continue-here.md` with detailed
state so `/q:resume` can pick up exactly where you stopped.

---

## DEBUGGING

### Scientific Method Debug Session
```
/q:debug [describe the bug or paste the error message]
```

This creates a `DEBUG-{issue}.md` file that tracks the investigation:
1. **Observe** — gather symptoms, error messages, repro steps
2. **Hypothesize** — form a testable theory
3. **Test** — investigate and document findings
4. **Conclude** — confirm root cause or form new hypothesis (max 3)
5. **Fix** — implement and verify the fix
6. **Clean up** — commit, update todo.md, delete debug file

The debug file preserves progress across sessions — if context runs out
mid-investigation, `/q:resume` will pick up where you left off.

---

## SUBAGENT ROLES

Agent Q includes 4 subagent role definitions in `agents/`:

| Agent | Role | When Used |
|-------|------|-----------|
| q-planner | Creates build plans | `/q:plan`, planning sessions |
| q-executor | Executes plans atomically | `/q:execute`, build sessions |
| q-verifier | Verifies goal achievement | `/q:verify`, post-build review |
| q-debugger | Scientific method debugging | `/q:debug`, bug investigations |

For parallel execution, these can be spawned as Task subagents
(see `workflows/spin-jit-su-workflow.md` → "Subagent Spawning").
