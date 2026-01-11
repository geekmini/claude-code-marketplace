#!/bin/bash
# SessionStart hook: Load memory context at session start
# Provides app_id for project-scoped memory retrieval

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Get app_id using utility script
APP_ID=$("$PLUGIN_ROOT/scripts/get-app-id.sh")

# Build directive message (user_id is set via MEM0_USER_ID env var)
if [ -n "$APP_ID" ]; then
  MESSAGE="[mem0] REQUIRED: Include app_id=\"${APP_ID}\" in ALL mem0 tool calls (add_memory, search_memories, get_memories). This ensures memories are project-scoped."
else
  MESSAGE="[mem0] No app_id available (not in git repo). Memories will be stored globally."
fi

jq -n --arg msg "$MESSAGE" '{"systemMessage": $msg}'
