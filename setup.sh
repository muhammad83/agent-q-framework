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
echo "✓ Created folders: workflows/ tools/ templates/ clients/"

# Step 3: Copy CLAUDE.md from the framework repo
# If CLAUDE.md exists in parent (cloned from repo), copy it
if [ -f "../CLAUDE.md" ]; then
    cp ../CLAUDE.md ./CLAUDE.md
else
    touch CLAUDE.md
fi

# If backend-only, strip the Frontend Development section
if [ "$HAS_FRONTEND" != "y" ] && [ "$HAS_FRONTEND" != "Y" ]; then
    if [ -s "CLAUDE.md" ]; then
        # Remove everything from "## Frontend Development" to end of file
        sed -i.bak '/^## Frontend Development$/,$d' CLAUDE.md
        rm -f CLAUDE.md.bak
        echo "✓ CLAUDE.md ready (backend-only, frontend section removed)"
    else
        echo "✓ CLAUDE.md ready (fill in the [PLACEHOLDERS])"
    fi
else
    echo "✓ CLAUDE.md ready (with frontend rules)"
fi

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
2. Interview user about aesthetic direction and UI style preferences.
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
- Figma MCP (if configured, for reading design specs)

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

# Step 9: Set up Figma MCP (if frontend project)
if [ "$HAS_FRONTEND" = "y" ] || [ "$HAS_FRONTEND" = "Y" ]; then
    echo ""
    echo "--- Figma MCP Setup (Optional) ---"
    read -p "Do you have a Figma API token to set up now? (y/n): " HAS_FIGMA

    if [ "$HAS_FIGMA" = "y" ] || [ "$HAS_FIGMA" = "Y" ]; then
        read -p "Enter your Figma API token: " FIGMA_TOKEN

        # Create or update ~/.claude/mcp.json
        MCP_FILE="$HOME/.claude/mcp.json"
        mkdir -p "$HOME/.claude"

        if [ -f "$MCP_FILE" ]; then
            if grep -q "figma" "$MCP_FILE" 2>/dev/null; then
                echo "✓ Figma MCP already configured in $MCP_FILE"
            else
                echo ""
                echo "⚠ MCP config already exists at $MCP_FILE"
                echo "  Please manually add this under mcpServers:"
                echo ""
                echo '    "figma": {'
                echo '      "command": "npx",'
                echo "      \"args\": [\"-y\", \"figma-developer-mcp\", \"--figma-api-key=$FIGMA_TOKEN\"]"
                echo '    }'
                echo ""
            fi
        else
            cat > "$MCP_FILE" << MCPEOF
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": ["-y", "figma-developer-mcp", "--figma-api-key=$FIGMA_TOKEN"]
    }
  }
}
MCPEOF
            echo "✓ Created $MCP_FILE with Figma MCP"
        fi
    else
        echo "✓ Skipped Figma setup — add it later with: claude mcp add figma"
    fi
fi

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
echo "    CLAUDE.md          — Agent brain (edit the [PLACEHOLDERS])"
echo "    todo.md            — Project state tracker"
echo "    workflows/         — Step-by-step instructions"
echo "    tools/             — Executable scripts"
echo "    clients/           — Per-client data"
echo "    templates/         — Reusable templates"
echo "    .env.example       — API key template"
echo "    .gitignore         — Keeps secrets out of git"

if [ "$HAS_FRONTEND" = "y" ] || [ "$HAS_FRONTEND" = "Y" ]; then
    echo ""
    echo "  Frontend:            ENABLED"
    echo "  Frontend workflow:   workflows/frontend-build.md"
    if [ "$HAS_FIGMA" = "y" ] || [ "$HAS_FIGMA" = "Y" ]; then
        echo "  Figma MCP:           CONFIGURED"
    else
        echo "  Figma MCP:           SKIPPED (add later)"
    fi
else
    echo ""
    echo "  Frontend:            DISABLED (backend-only)"
fi

echo ""
echo "  Next steps:"
echo "  1. cd $PROJECT_NAME"
echo "  2. Open CLAUDE.md and fill in the [PLACEHOLDERS]"
echo "  3. Open todo.md and set your first goal"
echo "  4. cp .env.example .env and add your real keys"
echo "  5. Run 'claude' to start Phase 2 (Planning)"
echo ""
