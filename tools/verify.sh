#!/bin/bash

# Agent Q Framework — Boolean Verification Script
# Usage: ./tools/verify.sh <filepath>
# Runs pass/fail checks against any output file.
# Customize the CHECKS array below for your project.

if [ -z "$1" ]; then
  echo "Usage: ./tools/verify.sh <filepath>"
  exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
  echo "Error: File not found: $FILE"
  exit 1
fi

# Each check is "Label:::grep_pattern"
CHECKS=(
  "Has Next Steps section:::## Next Steps"
  "Has specific dates or deadlines:::[0-9]{4}-[0-9]{2}-[0-9]{2}|deadline|due date"
  "Has at least one action item:::- \[ \]|Action:"
)

PASS=0
FAIL=0
TOTAL=${#CHECKS[@]}

echo ""
echo "Verifying: $FILE"
echo "-----------------------------------"

for check in "${CHECKS[@]}"; do
  LABEL="${check%%:::*}"
  PATTERN="${check##*:::}"

  if grep -qE -- "$PATTERN" "$FILE" 2>/dev/null; then
    echo "✅ $LABEL"
    ((PASS++))
  else
    echo "❌ $LABEL"
    ((FAIL++))
  fi
done

echo "-----------------------------------"
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "VERIFICATION FAILED"
  exit 1
else
  echo "VERIFICATION PASSED"
  exit 0
fi
