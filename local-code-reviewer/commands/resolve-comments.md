---
name: resolve-comments
description: Resolve GitHub PR review comments interactively. Fetches unresolved threads, helps fix issues, posts replies, and resolves threads.
argument-hint: "[pr-number] [--guideline path]"
allowed-tools: ["Read", "Glob", "Grep", "Bash", "Edit", "Write", "AskUserQuestion", "TodoWrite"]
---

# Resolve PR Comments Command

Interactively resolve GitHub PR review comments by fetching unresolved threads, helping fix issues, posting replies, and resolving threads.

## Arguments

```
$ARGUMENTS
```

Parse the arguments:
- If PR number provided, use it
- If `--guideline <path>` provided, use that path
- Otherwise, auto-detect PR from current branch and use default guideline: `docs/codeReviewGuideline.md`

## Workflow

Execute the `resolve-pr-comments` skill workflow:

1. **Resolve PR number** - From argument or auto-detect from current branch using `gh pr view`
2. **Get repository info** - Using `gh repo view`
3. **Read guideline** - Load from specified path or default
4. **Fetch PR comments** - Get inline review comments, review threads, and general comments
5. **Filter to unresolved** - Skip already resolved threads
6. **Interactive loop** - For each comment: analyze, propose fix, get user decision
7. **Apply fixes and reply** - Post replies and resolve threads
8. **Commit changes** - If fixes were applied
9. **Offer to push** - Ask if user wants to push

## User Options

**For inline comments:**
- **Fix** - Apply change, post reply, resolve thread
- **Skip** - Move to next comment
- **Resolve** - Mark resolved with explanation

**For general comments:**
- **Fix** - Apply changes and post reply
- **Skip** - Move to next comment
- **Acknowledge** - Reply with explanation

## Progress Display

Show progress throughout:
```
Progress: X of Y comments (F fixed, S skipped, R resolved, A acknowledged)
```

## Constraints

- Process comments one by one
- Post replies before resolving threads
- Do NOT modify other users' comments
- Show clear progress indicators
- Use `gh` CLI for all GitHub API interactions
