#!/bin/bash
# SessionStart hook: Load memory context at session start
# Provides app_id for project-scoped memory retrieval

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Get app_id using utility script
APP_ID=$("$PLUGIN_ROOT/scripts/get-app-id.sh")

# Build informational message (user_id is set via MEM0_USER_ID env var)
if [ -n "$APP_ID" ]; then
  MESSAGE="[mem0] app_id=\"${APP_ID}\" available for project-scoped memories. Use this app_id ONLY for project-specific memories. Omit app_id for user preferences (global memories)."
else
  MESSAGE="[mem0] No app_id available (not in git repo). All memories will be user-scoped (global)."
fi

jq -n --arg msg "$MESSAGE" '{"systemMessage": $msg}'
