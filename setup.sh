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

# Step 1: Create project folder
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Step 2: Create folder structure
mkdir -p workflows
mkdir -p tools
mkdir -p templates
echo "✓ Created folders: workflows/ tools/ templates/"

# Step 3: Copy template files
# (If cloned from repo, these are already in place)
# If running standalone, create empty essentials
touch CLAUDE.md
touch todo.md
touch .env
touch .gitignore
echo "✓ Created core files: CLAUDE.md, todo.md, .env, .gitignore"

# Step 4: Create workflow template
mkdir -p workflows
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

# Step 5: Set up gitignore
cat > .gitignore << 'EOF'
.env
__pycache__/
*.pyc
node_modules/
.DS_Store
*.log
EOF
echo "✓ Set up .gitignore"

echo ""
echo "=========================================="
echo "  SETUP COMPLETE"
echo "=========================================="
echo ""
echo "  Next steps:"
echo "  1. cd $PROJECT_NAME"
echo "  2. Open CLAUDE.md and fill in the [PLACEHOLDERS]"
echo "  3. Open todo.md and set your first goal"
echo "  4. Copy .env.example to .env and add your keys"
echo "  5. Run 'claude' to start Phase 2 (Planning)"
echo ""
