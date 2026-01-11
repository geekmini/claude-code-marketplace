#!/bin/bash
# SessionStart hook: Load memory context at session start
# Provides app_id for project-scoped memory retrieval

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Get app_id using utility script
APP_ID=$("$PLUGIN_ROOT/scripts/get-app-id.sh")

# Build detailed scope detection message (user_id is set via MEM0_USER_ID env var)
if [ -n "$APP_ID" ]; then
  MESSAGE="[mem0 SCOPE RULES] When calling mem0 tools, you MUST determine the correct scope:

USER-SCOPED (NO app_id) - for personal preferences that apply across ALL projects:
- \"I prefer/like X\" → NO app_id
- \"My name is X\" → NO app_id
- \"I always use X\" → NO app_id
- Coding style, communication preferences, personal info → NO app_id

PROJECT-SCOPED (WITH app_id=\"${APP_ID}\") - ONLY for info specific to THIS repo:
- \"This project/repo uses X\" → app_id=\"${APP_ID}\"
- \"For this codebase\" → app_id=\"${APP_ID}\"
- Architecture decisions, file locations, project dependencies → app_id=\"${APP_ID}\"

DEFAULT: If unclear, use NO app_id (user-scoped)."
else
  MESSAGE="[mem0] No app_id available (not in git repo). All memories will be user-scoped (no app_id parameter needed)."
fi

jq -n --arg msg "$MESSAGE" '{"systemMessage": $msg}'
