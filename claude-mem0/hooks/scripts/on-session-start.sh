#!/bin/bash
# SessionStart hook: Load memory context at session start
# Provides user_id and app_id for memory retrieval

set -euo pipefail

# Get user_id from environment variable (set via MEM0_USER_ID)
# Falls back to system username if not set
USER_ID="${MEM0_USER_ID:-${USER:-mem0-user}}"

# Get project identifier from git remote URL hash
APP_ID=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
  if [ -n "$REMOTE_URL" ]; then
    APP_ID=$(echo -n "$REMOTE_URL" | shasum -a 256 | cut -c1-16)
  fi
fi

# Build concise reminder
if [ -n "$APP_ID" ]; then
  MESSAGE="mem0: Search relevant memories with search_memories (user_id=\"${USER_ID}\", app_id=\"${APP_ID}\" for project-specific)"
else
  MESSAGE="mem0: Search relevant memories with search_memories (user_id=\"${USER_ID}\")"
fi

jq -n --arg msg "$MESSAGE" '{"systemMessage": $msg}'
