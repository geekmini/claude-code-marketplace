#!/bin/bash
# Stop hook: Capture task learnings to memory
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
  PROJECT_SECTION="**Project memories** - USE: user_id=\"${USER_ID}\" AND app_id=\"${PROJECT_ID}\"
- Architecture decisions made
- Codebase patterns discovered
- Bug fixes and their root causes
- Configuration or setup details"
  PROJECT_EXAMPLE="
Project memory (for this project only):
\`\`\`
add_memory(messages=\"API uses Express with JWT auth\", user_id=\"${USER_ID}\", app_id=\"${PROJECT_ID}\")
\`\`\`"
else
  PROJECT_SECTION="(No git remote detected - only save global memories, do NOT use app_id)"
  PROJECT_EXAMPLE=""
fi

MESSAGE="# Memory Capture - Task Completion

Before completing, save any valuable learnings using \`add_memory\`.

## Memory Scoping - IMPORTANT

**Global memories** - USE: user_id=\"${USER_ID}\" (do NOT include app_id)
- User preferences (coding style, tools)
- Personal info (name, role, expertise)

${PROJECT_SECTION}

## Example Calls

Global memory (accessible from all projects):
\`\`\`
add_memory(messages=\"User prefers TypeScript\", user_id=\"${USER_ID}\")
\`\`\`
${PROJECT_EXAMPLE}

## Action

Save memories if valuable, then return \`approve\` to stop."

jq -n --arg msg "$MESSAGE" '{"decision": "approve", "systemMessage": $msg}'
