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
mkdir -p .github
echo "✓ Created folders: workflows/ tools/ templates/ clients/ rules/ context/ shared_context/ .github/"

# Step 3: Copy framework files
# Copy context files from the framework repo
if [ -d "../context" ]; then
    cp ../context/rules.md ./context/rules.md
    cp ../context/planning-protocol.md ./context/planning-protocol.md
    cp ../context/engineering-preferences.md ./context/engineering-preferences.md
    cp ../context/frontend.md ./context/frontend.md
    echo "✓ Copied context/ files (rules, planning, preferences, frontend)"
fi

# Copy CLAUDE.md
if [ -f "../CLAUDE.md" ]; then
    cp ../CLAUDE.md ./CLAUDE.md
else
    touch CLAUDE.md
fi
echo "✓ CLAUDE.md ready (fill in the [PLACEHOLDERS])"

# Copy agent.md (OpenAI Codex)
if [ -f "../agent.md" ]; then
    cp ../agent.md ./agent.md
    echo "✓ Copied agent.md (OpenAI Codex)"
fi

# Copy .github/copilot-instructions.md (GitHub Copilot)
if [ -f "../.github/copilot-instructions.md" ]; then
    cp ../.github/copilot-instructions.md ./.github/copilot-instructions.md
    echo "✓ Copied .github/copilot-instructions.md (GitHub Copilot)"
fi

# If backend-only, delete context/frontend.md
if [ "$HAS_FRONTEND" != "y" ] && [ "$HAS_FRONTEND" != "Y" ]; then
    rm -f context/frontend.md
    echo "✓ Removed context/frontend.md (backend-only project)"
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
if [ -f "../rules/_TEMPLATE.md" ]; then
    cp ../rules/_TEMPLATE.md ./rules/_TEMPLATE.md
    echo "✓ Copied rules/_TEMPLATE.md"
fi
if [ -f "../tools/verify.sh" ]; then
    cp ../tools/verify.sh ./tools/verify.sh
    chmod +x ./tools/verify.sh
    echo "✓ Copied tools/verify.sh"
fi

# Soul — agent personality (agent writes its own)
if [ -f "../soul.md" ]; then
    cp ../soul.md ./soul.md
    echo "✓ Copied soul.md"
fi

# Heartbeat — proactive monitoring (optional)
if [ -f "../tools/heartbeat.sh" ]; then
    cp ../tools/heartbeat.sh ./tools/heartbeat.sh
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
echo "    context/           — Framework rules & preferences (shared)"
echo "    shared_context/    — Project-specific domain knowledge"
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
