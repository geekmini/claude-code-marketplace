#!/bin/bash
# Stop hook: Remind to capture task learnings to memory
# Provides app_id for project-scoped memory storage

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Get app_id using utility script
APP_ID=$("$PLUGIN_ROOT/scripts/get-app-id.sh")

# Build concise reminder (user_id is set via MEM0_USER_ID env var)
if [ -n "$APP_ID" ]; then
  MESSAGE="mem0: app_id=\"${APP_ID}\" for project-scoped memories"
else
  MESSAGE="mem0: no app_id (not in a git repo with remote)"
fi

jq -n --arg msg "$MESSAGE" '{"decision": "approve", "systemMessage": $msg}'
