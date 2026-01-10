#!/bin/bash
# Get the user identifier for mem0 memory scoping
# Used for identifying the user across all memories

set -euo pipefail

# Priority: MEM0_USER_ID env var > system $USER > fallback
echo "${MEM0_USER_ID:-${USER:-mem0-user}}"
