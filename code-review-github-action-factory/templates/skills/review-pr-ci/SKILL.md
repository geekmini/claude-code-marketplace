---
name: review-pr-ci
description: This skill should be used when running automated code review in CI environments like GitHub Actions. Triggers on "review PR in CI", "automated code review", "CI review", or when running in GitHub Actions with GITHUB_ACTIONS=true. Posts inline comments for critical issues and a summary comment.
---

# CI Code Review

Perform automated code review in CI with intelligent comment management and semantic deduplication.

## CI Environment Requirement

**This skill is for CI automation only.**

Check environment:
```bash
echo "CI=$CI, GITHUB_ACTIONS=$GITHUB_ACTIONS"
```

If NOT in CI (both empty), show error and suggest alternatives:
- `review-and-fix` - Local review without PR
- `resolve-pr-comments` - Address reviewer feedback

## Quick Workflow

1. Read guidelines from `{GUIDELINE_PATH}` and `CLAUDE.md` (if exists)
2. Analyze PR using `gh pr view` and `gh pr diff`
3. Classify issues as CRITICAL (inline) or SUGGESTIONS (summary only)
4. Deduplicate against existing unresolved comments
5. Post/update comments and summary

## Issue Classification

**CRITICAL** (posted as inline comments):
- Bugs causing failures
- Security vulnerabilities
- Code health degradation
- Architectural violations

**SUGGESTIONS** (summary table only):
- Style inconsistencies
- Alternative approaches
- Educational comments
- Optional refactoring

## Detailed Workflow

See [references/workflow.md](references/workflow.md) for:
- Complete 6-phase workflow
- Semantic deduplication algorithm
- Comment reconciliation logic
- Error handling
