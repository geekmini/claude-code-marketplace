---
name: resolve-pr-comments
description: This skill should be used when addressing feedback from code reviewers on a pull request. Triggers on "resolve PR comments", "address review feedback", "fix reviewer comments", "respond to PR feedback", or when working through unresolved review threads.
---

# Resolve PR Comments

Interactively resolve GitHub PR review comments by fetching unresolved threads, helping fix issues, posting replies, and resolving threads.

## Guideline Path

Accept optional guideline path to evaluate if reviewer feedback aligns with standards.
Default: `docs/codeReviewGuideline.md`

Example:
- `resolve PR comments` (uses default)
- `resolve PR comments with guideline at .github/REVIEW.md`

## Quick Workflow

1. Auto-detect PR from current branch (or accept PR number)
2. Read guideline for context on review standards
3. Fetch all unresolved review threads
4. For each comment: analyze, propose fix, get user decision
5. Fix/Skip/Resolve based on user choice
6. Commit changes and optionally push

## User Options

**For inline comments:**
- **Fix** - Apply change and reply
- **Skip** - Move to next
- **Resolve** - Mark resolved with reason

**For general comments:**
- **Fix** - Apply changes and reply
- **Skip** - Move to next
- **Acknowledge** - Reply with explanation

## Constraints

- Process comments one by one
- Post replies before resolving threads
- Do NOT modify other users' comments
- Show clear progress indicators

## Detailed Workflow

See [references/workflow.md](references/workflow.md) for complete phases and GitHub API usage.
