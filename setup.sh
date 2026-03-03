#!/bin/bash

# Agent Q Framework — New Project Setup Script
# Usage: ./setup.sh my-project-name

# Check if project name was given
if [ -z "$1" ]; then
  echo "Usage: ./setup.sh your-project-name"
  echo "Example: ./setup.sh sales-agent"
  exit 1
fi

PROJECT_NAME=$1
FRAMEWORK_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=========================================="
echo "  Agent Q Framework — Setting up: $PROJECT_NAME"
echo "=========================================="
echo ""

# Step 0: Ask about project type
read -p "Does this project include a frontend? (y/n): " HAS_FRONTEND
echo ""

# Step 1: Create project folder
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Step 2: Create folder structure
mkdir -p workflows
mkdir -p tools
mkdir -p templates
mkdir -p clients
mkdir -p rules
mkdir -p context
mkdir -p shared_context
mkdir -p agents
mkdir -p hooks
mkdir -p .claude
mkdir -p .github
mkdir -p .agent/rules
echo "✓ Created folders: workflows/ tools/ templates/ clients/ rules/ context/ shared_context/ agents/ hooks/ .claude/ .github/ .agent/rules/"

# Step 3: Symlink shared framework files (single source of truth)
# Context files are symlinked so updates to the framework propagate to all projects
if [ -d "$FRAMEWORK_DIR/context" ]; then
    ln -s "$FRAMEWORK_DIR/context/rules.md" ./context/rules.md
    ln -s "$FRAMEWORK_DIR/context/planning-protocol.md" ./context/planning-protocol.md
    ln -s "$FRAMEWORK_DIR/context/engineering-preferences.md" ./context/engineering-preferences.md
    ln -s "$FRAMEWORK_DIR/context/frontend.md" ./context/frontend.md
    echo "✓ Symlinked context/ files → framework (rules, planning, preferences, frontend)"
fi

# Symlink shared workflows from the framework
if [ -d "$FRAMEWORK_DIR/workflows" ]; then
    ln -s "$FRAMEWORK_DIR/workflows/code-review.md" ./workflows/code-review.md
    ln -s "$FRAMEWORK_DIR/workflows/pause.md" ./workflows/pause.md
    ln -s "$FRAMEWORK_DIR/workflows/resume.md" ./workflows/resume.md
    ln -s "$FRAMEWORK_DIR/workflows/debug.md" ./workflows/debug.md
    echo "✓ Symlinked workflows/ → framework (code-review, pause, resume, debug)"
fi

# Symlink hooks from the framework
if [ -d "$FRAMEWORK_DIR/hooks" ]; then
    ln -s "$FRAMEWORK_DIR/hooks/agentq-statusline.js" ./hooks/agentq-statusline.js
    ln -s "$FRAMEWORK_DIR/hooks/agentq-context-monitor.js" ./hooks/agentq-context-monitor.js
    echo "✓ Symlinked hooks/ → framework (statusline, context monitor)"
fi

# Symlink slash commands from the framework
if [ -d "$FRAMEWORK_DIR/commands" ]; then
    ln -s "$FRAMEWORK_DIR/commands" ./commands
    echo "✓ Symlinked commands/ → framework (slash commands)"
fi

# Copy agent role definitions (projects may customize these)
if [ -d "$FRAMEWORK_DIR/agents" ]; then
    cp "$FRAMEWORK_DIR/agents/q-planner.md" ./agents/q-planner.md
    cp "$FRAMEWORK_DIR/agents/q-executor.md" ./agents/q-executor.md
    cp "$FRAMEWORK_DIR/agents/q-verifier.md" ./agents/q-verifier.md
    cp "$FRAMEWORK_DIR/agents/q-debugger.md" ./agents/q-debugger.md
    echo "✓ Copied agents/ (planner, executor, verifier, debugger)"
fi

# Create .claude/settings.json with hook configuration
cat > .claude/settings.json << 'EOF'
{
  "hooks": {
    "PostToolUse": [
      {
        "type": "command",
        "command": "node hooks/agentq-context-monitor.js"
      }
    ]
  },
  "statusLine": "node hooks/agentq-statusline.js"
}
EOF
echo "✓ Created .claude/settings.json (hooks + statusline)"

# Copy CLAUDE.md
if [ -f "$FRAMEWORK_DIR/CLAUDE.md" ]; then
    cp "$FRAMEWORK_DIR/CLAUDE.md" ./CLAUDE.md
else
    touch CLAUDE.md
fi
echo "✓ CLAUDE.md ready (fill in the [PLACEHOLDERS])"

# Copy agent.md (OpenAI Codex)
if [ -f "$FRAMEWORK_DIR/agent.md" ]; then
    cp "$FRAMEWORK_DIR/agent.md" ./agent.md
    echo "✓ Copied agent.md (OpenAI Codex)"
fi

# Copy .github/copilot-instructions.md (GitHub Copilot)
if [ -f "$FRAMEWORK_DIR/.github/copilot-instructions.md" ]; then
    cp "$FRAMEWORK_DIR/.github/copilot-instructions.md" ./.github/copilot-instructions.md
    echo "✓ Copied .github/copilot-instructions.md (GitHub Copilot)"
fi

# Copy .agent/rules/agent-q.md (Google Antigravity)
if [ -f "$FRAMEWORK_DIR/.agent/rules/agent-q.md" ]; then
    cp "$FRAMEWORK_DIR/.agent/rules/agent-q.md" ./.agent/rules/agent-q.md
    echo "✓ Copied .agent/rules/agent-q.md (Google Antigravity)"
fi

# If backend-only, remove frontend symlink
if [ "$HAS_FRONTEND" != "y" ] && [ "$HAS_FRONTEND" != "Y" ]; then
    rm -f context/frontend.md
    echo "✓ Removed context/frontend.md symlink (backend-only project)"
fi

# Create shared_context/README.md
cat > shared_context/README.md << 'EOF'
Put your project-specific domain knowledge here (personas, frameworks, domain rules). These are referenced by all AI tools but are specific to THIS project, not the Agent Q framework.
EOF
echo "✓ Created shared_context/README.md"

# Step 4: Create todo.md
cat > todo.md << 'EOF'
# [PROJECT NAME] — Project State

## Current Goal
- [ ] [WHAT ARE YOU TRYING TO ACCOMPLISH RIGHT NOW?]

## Active Tasks
- [ ] [TASK 1]
- [ ] [TASK 2]

## Completed
- (nothing yet)

## Decisions Made
[RECORD KEY DECISIONS HERE SO FUTURE SESSIONS HAVE CONTEXT]
- (none yet)

## Known Issues
- (none yet)

## Session Log
[UPDATE THIS AT THE END OF EVERY SESSION]

### Session 1 — [DATE]
- What was done:
- What's next:
- Blockers:
EOF
echo "✓ Created todo.md"

# Step 5: Create workflow template
cat > workflows/_TEMPLATE.md << 'EOF'
# Workflow: [NAME]

## Trigger
Run this when [DESCRIBE THE CONDITION THAT TRIGGERS THIS WORKFLOW].

## Context Needed
Before running, make sure you have:
- [ ] [WHAT FILES OR INFO DOES CLAUDE NEED TO READ FIRST?]
- [ ] [ANY EXTERNAL INPUTS NEEDED?]

## Steps
1. Read todo.md for current project state.
2. [STEP 2 — BE SPECIFIC]
3. [STEP 3 — BE SPECIFIC]
4. [STEP 4 — BE SPECIFIC]
5. Update todo.md with results.

## Tools Used
- tools/[WHICH SCRIPTS DOES THIS WORKFLOW CALL?]

## Output
- [WHAT FILES GET CREATED OR UPDATED?]
- [WHERE DO THEY GET SAVED?]

## Success Criteria
- [HOW DO YOU KNOW IT WORKED? BE MEASURABLE]
- [WHAT SHOULD THE OUTPUT LOOK LIKE?]

## Edge Cases
- [WHAT COULD GO WRONG?]
- [WHAT SHOULD CLAUDE DO IF X HAPPENS?]
EOF
echo "✓ Created workflow template"

# Step 5b: Copy rules template and verify script from framework repo
if [ -f "$FRAMEWORK_DIR/rules/_TEMPLATE.md" ]; then
    cp "$FRAMEWORK_DIR/rules/_TEMPLATE.md" ./rules/_TEMPLATE.md
    echo "✓ Copied rules/_TEMPLATE.md"
fi
if [ -f "$FRAMEWORK_DIR/tools/verify.sh" ]; then
    cp "$FRAMEWORK_DIR/tools/verify.sh" ./tools/verify.sh
    chmod +x ./tools/verify.sh
    echo "✓ Copied tools/verify.sh"
fi

# Soul — agent personality (agent writes its own)
if [ -f "$FRAMEWORK_DIR/soul.md" ]; then
    cp "$FRAMEWORK_DIR/soul.md" ./soul.md
    echo "✓ Copied soul.md"
fi

# Heartbeat — proactive monitoring (optional)
if [ -f "$FRAMEWORK_DIR/tools/heartbeat.sh" ]; then
    cp "$FRAMEWORK_DIR/tools/heartbeat.sh" ./tools/heartbeat.sh
    chmod +x ./tools/heartbeat.sh
    echo "✓ Copied tools/heartbeat.sh"
fi

# Step 6: Create frontend workflow (if applicable)
if [ "$HAS_FRONTEND" = "y" ] || [ "$HAS_FRONTEND" = "Y" ]; then
    cat > workflows/frontend-build.md << 'EOF'
# Workflow: Frontend Build

## Trigger
Run this when building or modifying any user interface component.

## Context Needed
Before running, make sure you have:
- [ ] Aesthetic direction confirmed with user (minimal, dashboard, sleek, etc.)
- [ ] Reference designs or Figma links (if available)
- [ ] Frontend-design skill loaded

## Steps
1. Read todo.md for current project state.
2. Check brand_assets/ for reference screenshots and CSS files. If present, use those as the design source. If not, ask the user for a reference site URL or aesthetic direction.
3. Load the frontend-design skill.
4. Build the component or page.
5. Open in browser using /chrome and take a screenshot.
6. Compare against reference design if one was provided.
7. Critique own layout for spacing, colors, alignment, responsiveness.
8. Fix any visual issues found.
9. Take final screenshot for confirmation.
10. Update todo.md with results.

## Tools Used
- /chrome (visual verification)
- Reference screenshots and CSS from brand_assets/

## Output
- UI component files (HTML/React/etc.)
- Screenshot of final result

## Success Criteria
- Component matches agreed aesthetic direction
- No obvious spacing, alignment, or color issues
- Responsive on mobile and desktop viewports
- User confirms visual approval

## Edge Cases
- If /chrome is not available, ask user to check manually and provide feedback
- If Figma MCP is not configured, ask user to paste or describe the design
- If user says "you decide" on aesthetics, default to clean/minimal
EOF
    echo "✓ Created workflows/frontend-build.md"

    # Create brand_assets/ folder for design references
    mkdir -p brand_assets
    touch brand_assets/.gitkeep
    cat > brand_assets/README.md << 'EOF'
Drop these files here before building UI:
- Your logo (PNG/SVG)
- Brand guidelines PDF (colors, typography, spacing)
- Reference screenshots of sites you want to match
- CSS copied from reference site dev tools (save as reference-styles.css)
EOF
    echo "✓ Created brand_assets/ with README"
fi

# Step 7: Set up .env.example
if [ "$HAS_FRONTEND" = "y" ] || [ "$HAS_FRONTEND" = "Y" ]; then
    cat > .env.example << 'EOF'
# Environment Variables — NEVER COMMIT THIS FILE
# Copy this to .env and fill in your real values

# Anthropic API (if using Claude API in your tools)
ANTHROPIC_API_KEY=sk-ant-your-key-here

# Optional: Figma integration (for frontend projects)
# FIGMA_API_TOKEN=your-figma-token-here

# Add any other secrets below
# DATABASE_URL=
# SLACK_WEBHOOK_URL=
# RECALL_AI_KEY=
EOF
else
    cat > .env.example << 'EOF'
# Environment Variables — NEVER COMMIT THIS FILE
# Copy this to .env and fill in your real values

# Anthropic API (if using Claude API in your tools)
ANTHROPIC_API_KEY=sk-ant-your-key-here

# Add any other secrets below
# DATABASE_URL=
# SLACK_WEBHOOK_URL=
# RECALL_AI_KEY=
EOF
fi
echo "✓ Created .env.example"

# Step 8: Set up gitignore
cat > .gitignore << 'EOF'
# Secrets
.env

# Python
__pycache__/
*.pyc
*.pyo
venv/
.venv/

# Node
node_modules/

# OS files
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/

# Logs
*.log
EOF
echo "✓ Set up .gitignore"

# Optional: If you use Figma, add MCP manually:
# claude mcp add figma -- npx -y figma-developer-mcp --figma-api-key=YOUR_KEY

# Step 10: Initialize git
git init
git add -A
git commit -m "Initial setup from Agent Q Framework"
echo "✓ Initialized git repo"

# Summary
echo ""
echo "=========================================="
echo "  SETUP COMPLETE"
echo "=========================================="
echo ""
echo "  Project structure:"
echo "    CLAUDE.md          — Claude Code config (thin pointer)"
echo "    agent.md           — OpenAI Codex config (thin pointer)"
echo "    .github/copilot-instructions.md — GitHub Copilot config"
echo "    .agent/rules/agent-q.md — Google Antigravity config"
echo "    context/           — Framework rules & preferences (symlinked)"
echo "    shared_context/    — Project-specific domain knowledge"
echo "    agents/            — Subagent role definitions (planner, executor, verifier, debugger)"
echo "    hooks/             — Context monitor & statusline (symlinked)"
echo "    commands/          — Slash commands /q:plan, /q:execute, etc. (symlinked)"
echo "    .claude/           — Claude Code settings (hooks config)"
echo "    todo.md            — Project state tracker"
echo "    workflows/         — Step-by-step instructions"
echo "    tools/             — Executable scripts"
echo "    rules/             — Engineering rules"
echo "    clients/           — Per-client data"
echo "    templates/         — Reusable templates"
echo "    .env.example       — API key template"
echo "    .gitignore         — Keeps secrets out of git"

if [ "$HAS_FRONTEND" = "y" ] || [ "$HAS_FRONTEND" = "Y" ]; then
    echo ""
    echo "  Frontend:            ENABLED"
    echo "  Frontend workflow:   workflows/frontend-build.md"
    echo "  Frontend rules:      context/frontend.md"
    echo "  Brand assets:        brand_assets/"
else
    echo ""
    echo "  Frontend:            DISABLED (backend-only)"
fi

echo ""
echo "  Next steps:"
echo "  1. cd $PROJECT_NAME"
echo "  2. cp .env.example .env and add your real keys"
echo "  3. Run 'claude' and describe your project"
echo "     Claude will fill in CLAUDE.md and todo.md for you"
echo "  4. Follow QUICKSTART.md or CHEATSHEET.md from there"
echo ""
