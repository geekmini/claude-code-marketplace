#!/bin/bash
# SessionStart hook: Load memory context at session start
# Provides user_id and app_id for memory retrieval

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Get user_id and app_id using utility scripts
USER_ID=$("$PLUGIN_ROOT/scripts/get-user-id.sh")
APP_ID=$("$PLUGIN_ROOT/scripts/get-app-id.sh")

# Build concise reminder
if [ -n "$APP_ID" ]; then
  MESSAGE="mem0: user_id=\"${USER_ID}\", app_id=\"${APP_ID}\""
else
  MESSAGE="mem0: user_id=\"${USER_ID}\""
fi

jq -n --arg msg "$MESSAGE" '{"systemMessage": $msg}'
