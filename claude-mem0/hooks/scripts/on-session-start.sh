#!/bin/bash
# SessionStart hook: Load memory context at session start
# Instructs Claude to retrieve relevant memories from mem0

set -euo pipefail

# Get user_id from environment variable (set via MEM0_USER_ID)
# Falls back to system username if not set
USER_ID="${MEM0_USER_ID:-${USER:-mem0-user}}"

# Get project identifier from git remote URL hash
PROJECT_ID=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
  if [ -n "$REMOTE_URL" ]; then
    # Create a hash of the remote URL for consistent project identification
    PROJECT_ID=$(echo -n "$REMOTE_URL" | shasum -a 256 | cut -c1-16)
  fi
fi

# Build the system message
if [ -n "$PROJECT_ID" ]; then
  PROJECT_INSTRUCTION="Use \`search_memories\` with user_id=\"${USER_ID}\" and filter by app_id=\"${PROJECT_ID}\" for project-specific context."
else
  PROJECT_INSTRUCTION="No git remote found - skip project-specific memory search."
fi

MESSAGE="## Memory Context (claude-mem0)

At the start of this session, retrieve relevant memories to provide personalized context:

1. **Global memories** (user preferences, coding style, general knowledge):
   Use \`search_memories\` with user_id=\"${USER_ID}\" to find relevant global context.

2. **Project memories** (architecture, patterns, past decisions):
   ${PROJECT_INSTRUCTION}

Search for memories relevant to the user's first message. Include key context in your response if found.

**Memory IDs for this session:**
- user_id: ${USER_ID}
- project_id: ${PROJECT_ID:-none}"

# Output as properly escaped JSON using jq
jq -n --arg msg "$MESSAGE" '{"systemMessage": $msg}'
