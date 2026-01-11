#!/bin/bash
# PreToolUse hook: Auto-inject app_id for project-scoped memories
# - Auto-injects app_id when in a git repo (so Claude doesn't need to specify it)
# - Fixes invalid app_id values (repo names instead of hash)
# - Safety fallback: converts agent_id to app_id if mistakenly used

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Read input from stdin
INPUT=$(cat)

# Extract tool input
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // "{}"')

# Get current values
AGENT_ID=$(echo "$TOOL_INPUT" | jq -r '.agent_id // empty')
APP_ID=$(echo "$TOOL_INPUT" | jq -r '.app_id // empty')

# Get the correct app_id hash for this project
CORRECT_APP_ID=$("$PLUGIN_ROOT/scripts/get-app-id.sh" 2>/dev/null || echo "")

# Track if we need to fix anything
NEEDS_FIX=false
MESSAGES=()

# Check 1: agent_id is being used (should be app_id for project scope)
if [ -n "$AGENT_ID" ]; then
  NEEDS_FIX=true
  MESSAGES+=("Detected agent_id=\"$AGENT_ID\" - should use app_id for project-scoped memories")
fi

# Check 2: app_id doesn't look like a valid 16-char hex hash
if [ -n "$APP_ID" ]; then
  # Valid hash is exactly 16 hex characters
  if ! echo "$APP_ID" | grep -qE '^[a-f0-9]{16}$'; then
    NEEDS_FIX=true
    MESSAGES+=("Detected app_id=\"$APP_ID\" - should be 16-char hex hash, not repo name")
  fi
fi

# Check 3: No app_id provided but we're in a git repo (auto-inject for project scoping)
if [ -z "$APP_ID" ] && [ -z "$AGENT_ID" ] && [ -n "$CORRECT_APP_ID" ]; then
  NEEDS_FIX=true
  MESSAGES+=("No app_id provided - auto-injecting for project-scoped memory")
fi

# If no fixes needed, allow the call
if [ "$NEEDS_FIX" = false ]; then
  echo '{"decision": "allow"}'
  exit 0
fi

# Build the corrected tool input
UPDATED_INPUT="$TOOL_INPUT"

# Remove agent_id if present
if [ -n "$AGENT_ID" ]; then
  UPDATED_INPUT=$(echo "$UPDATED_INPUT" | jq 'del(.agent_id)')
fi

# Set correct app_id if we have one
if [ -n "$CORRECT_APP_ID" ]; then
  UPDATED_INPUT=$(echo "$UPDATED_INPUT" | jq --arg app_id "$CORRECT_APP_ID" '.app_id = $app_id')
  MESSAGES+=("Auto-fixed: app_id=\"$CORRECT_APP_ID\"")
else
  # No git remote, remove app_id entirely (global memory)
  UPDATED_INPUT=$(echo "$UPDATED_INPUT" | jq 'del(.app_id)')
  MESSAGES+=("Auto-fixed: removed app_id (not in git repo with remote)")
fi

# Build system message
SYSTEM_MSG=$(printf '%s\n' "${MESSAGES[@]}" | paste -sd '; ' -)

# Output with auto-fix
# NOTE: updatedInput must be at top level, NOT nested under hookSpecificOutput
jq -n \
  --arg msg "mem0 hook: $SYSTEM_MSG" \
  --argjson updated "$UPDATED_INPUT" \
  '{
    "decision": "allow",
    "updatedInput": $updated,
    "systemMessage": $msg
  }'
