#!/bin/bash
# SessionEnd hook: Capture session summary to memory
# Dynamically includes user_id and project_id

set -euo pipefail

# Get user_id from environment variable
USER_ID="${MEM0_USER_ID:-${USER:-mem0-user}}"

# Get project identifier from git remote URL hash
PROJECT_ID=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
  if [ -n "$REMOTE_URL" ]; then
    PROJECT_ID=$(echo -n "$REMOTE_URL" | shasum -a 256 | cut -c1-16)
  fi
fi

# Build prompt with actual IDs embedded
if [ -n "$PROJECT_ID" ]; then
  PARAMS_SECTION="- user_id: \"${USER_ID}\"
- app_id: \"${PROJECT_ID}\" (for project-specific memories)"
  WHAT_TO_CAPTURE="Session summary (project-scoped WITH app_id):
- Major tasks completed
- Key decisions made
- Problems solved

User updates (global, do NOT use app_id):
- New preferences discovered
- Updated understanding of user"
  EXAMPLE_CALL="add_memory(
  messages=\"Session: Implemented auth system with JWT\",
  user_id=\"${USER_ID}\",
  app_id=\"${PROJECT_ID}\"
)"
else
  PARAMS_SECTION="- user_id: \"${USER_ID}\"
- app_id: NOT AVAILABLE (no git remote - only save global memories)"
  WHAT_TO_CAPTURE="User updates (global only, do NOT use app_id):
- New preferences discovered
- Updated understanding of user
- Session accomplishments (without project context)"
  EXAMPLE_CALL="add_memory(
  messages=\"User completed a debugging session\",
  user_id=\"${USER_ID}\"
)"
fi

MESSAGE="# Memory Capture - Session End

Save a brief session summary before ending.

## Parameters

${PARAMS_SECTION}

## What to Capture

${WHAT_TO_CAPTURE}

## Example Call

\`\`\`
${EXAMPLE_CALL}
\`\`\`

Save relevant memories, then allow session to end."

jq -n --arg msg "$MESSAGE" '{"systemMessage": $msg}'
