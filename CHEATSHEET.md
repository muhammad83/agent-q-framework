# Agent Q Framework — Prompts & Commands Cheat Sheet

Keep this open during every session. These are the exact commands
and prompts you use at each phase.

---

## PHASE 1: SETUP

### Terminal Commands (run once per project)
```bash
git clone https://github.com/safqore/agent-q-framework.git my-project-name
cd my-project-name
rm -rf .git
git init
```

### Verification Prompt
Start Claude Code and paste this:
```
Read CLAUDE.md and the entire project structure.
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
Press: Shift+Tab

### Step 2 — Reverse Elicitation Prompt (copy this every time)
```
Read CLAUDE.md and all files in /workflows.

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
Press: Ctrl+G (opens in editor)
Read it. Edit anything you disagree with. Save.

### Step 5 — Switch to Code Mode
Press: Shift+Tab

### Step 6 — Execute
```
Read workflows/build-plan-{feature-name}.md and build everything
exactly as specified in the plan.
```

---

## PHASE 2B: CODE REVIEW (EXISTING CODE)

Use this after Phase 3 (build) is complete, before deployment.
Full prompt and instructions are in `workflows/code-review.md`.

### Quick version:
1. Enter Plan Mode: `Shift+Tab`
2. Open and paste the prompt from `workflows/code-review.md`
3. Choose BIG CHANGE (4 issues per section) or SMALL CHANGE (1 per section)
4. Work through: Architecture → Code Quality → Tests → Performance
5. Approve changes, exit Plan Mode: `Shift+Tab`
6. Tell Claude: `Execute all the changes we agreed on in the review.`
```

---

## PHASE 3: EXECUTION (STARCRAFT METHOD)

### Terminal Tab 1 — Builder
```bash
claude -dangerously-skip-permissions
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
/clear          — Wipe context, start fresh
/compact        — Summarize and compress current context
```

### The 2-Strike Rule
If you correct Claude twice on the same mistake:
1. Stop the session (Ctrl+C)
2. Update todo.md with what went wrong
3. Start a new session: `claude`
4. It reads todo.md and picks up with fresh context

---

## PHASE 4: VERIFICATION & DEPLOYMENT

### Visual Verification
```
/chrome
Open http://localhost:8000 and test every button. Take a
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

### Claude is stuck or looping
```
/clear
Read todo.md. What is the current state? What should we do next?
```

### Claude made a mess of the files
```
git diff                    — See what changed
git checkout -- .           — Undo all changes
git stash                   — Save changes but revert
```

### Claude broke something that was working
```
git log --oneline -10       — Find the last good commit
git checkout [commit-hash]  — Go back to it
```

---

## SESSION START TEMPLATE (use at the beginning of every session)

```
Read CLAUDE.md and todo.md. 

What is the current project state? What should we work on next?
Do not make any changes yet — just tell me your understanding.
```

## SESSION END TEMPLATE (use at the end of every session)

```
Update todo.md with:
1. Everything we accomplished this session
2. What we should do next session
3. Any known issues or blockers
4. Any decisions we made and why
```
