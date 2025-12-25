---
name: resolve-pr-comments
description: This skill should be used when addressing feedback from code reviewers on a pull request. Triggers on "resolve PR comments", "address review feedback", "fix reviewer comments", "respond to PR feedback", or when working through unresolved review threads.
---

# Resolve PR Comments

Interactively resolve GitHub PR review comments by fetching unresolved threads, helping fix issues, posting replies, and resolving threads.

## Quick Workflow

1. Fetch all unresolved inline and general PR comments
2. Present each with file context and severity assessment
3. User decides: Fix, Skip, Resolve, or Acknowledge
4. Apply changes, post replies, resolve threads
5. Stage changes and offer to commit/push

## PR Detection

Auto-detect from current branch or accept PR number:
```bash
gh pr view --json number,title --jq '"\(.number)|\(.title)"'
```

## Processing Order

1. **First**: Unresolved inline review comments
2. **Last**: General PR comments

## User Options

**For inline comments:**
- **Fix** - Apply code change, post reply, resolve thread
- **Skip** - Move to next without changes
- **Resolve** - Mark resolved without code changes (with reason)

**For general comments:**
- **Fix** - Apply code changes and reply
- **Skip** - Move to next
- **Acknowledge** - Reply with explanation

## Detailed Workflow

See [references/workflow.md](references/workflow.md) for:
- Complete fetch and filter logic
- GraphQL thread resolution
- Interactive loop details
- Progress tracking
