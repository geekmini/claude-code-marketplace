#!/bin/bash
# Get a consistent app identifier from git remote URL
# Used for scoping app-level memories in mem0

set -euo pipefail

# Check if we're in a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo ""
  exit 0
fi

# Get remote URL
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")

if [ -z "$REMOTE_URL" ]; then
  echo ""
  exit 0
fi

# Create a 16-character hash of the remote URL
# This provides consistent identification across clones
echo -n "$REMOTE_URL" | shasum -a 256 | cut -c1-16
