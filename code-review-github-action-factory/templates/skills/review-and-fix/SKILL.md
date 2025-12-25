---
name: review-and-fix
description: This skill should be used when reviewing local code changes before creating a PR. Triggers on "review my changes", "local code review", "review before PR", "check my code", or when reviewing changes that haven't been pushed yet.
---

# Local Code Review

Review local changes and fix issues interactively without needing a PR. Compares current branch against base branch.

## Quick Workflow

1. Detect current vs base branch (main/master)
2. Read guidelines from `{GUIDELINE_PATH}` and `CLAUDE.md` (if exists)
3. Analyze diff using `git diff base...HEAD`
4. Classify and sort: Critical → Major → Minor
5. Interactive loop: Fix, Skip, or Document each issue
6. Commit changes if fixes applied

## Branch Detection

Auto-detect base or accept as argument:
```bash
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
```
Falls back to `main` or `master`.

## Issue Classification

**Critical** - Must fix:
- Bugs, security vulnerabilities
- Anti-patterns per guideline

**Major** - Strong suggestions:
- Performance issues
- Poor maintainability

**Minor** - Nits:
- Style, naming
- Alternative approaches

## User Options

- **Fix** - Apply the change
- **Skip** - Move to next
- **Document** - Record as tech debt in `docs/technical_debt.md`

## Detailed Workflow

See [references/workflow.md](references/workflow.md) for:
- Complete review phases
- Interactive fix loop details
- Tech debt documentation format

## Constraints

- Do NOT post GitHub comments (local-only)
- Do NOT interact with GitHub API
- Show clear progress indicators
