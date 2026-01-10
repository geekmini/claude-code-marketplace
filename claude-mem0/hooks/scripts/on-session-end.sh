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
MESSAGE="# Memory Capture - Session End

Save a brief session summary before ending.

## Required Parameters

- user_id: \"${USER_ID}\"
- app_id: \"${PROJECT_ID:-none}\" (for project-specific memories)

## What to Capture

Session summary (project-scoped with app_id):
- Major tasks completed
- Key decisions made
- Problems solved

User updates (global, NO app_id):
- New preferences discovered
- Updated understanding of user

## Example Call

\`\`\`
add_memory(
  messages=\"Session: Implemented auth system with JWT, fixed CORS issues\",
  user_id=\"${USER_ID}\",
  app_id=\"${PROJECT_ID}\"
)
\`\`\`

Save relevant memories, then allow session to end."

jq -n --arg msg "$MESSAGE" '{"systemMessage": $msg}'
