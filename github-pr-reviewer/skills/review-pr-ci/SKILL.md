---
name: review-pr-ci
description: This skill should be used when running automated code review in CI environments like GitHub Actions. Triggers on "review PR", "review this PR", "code review", "review PR in CI", or when running with GITHUB_ACTIONS=true environment variable.
---

# CI Code Review

Perform automated PR code review with intelligent comment management and semantic deduplication.

## CI Environment Check

Verify running in CI:
```bash
echo "GITHUB_ACTIONS=$GITHUB_ACTIONS"
```

If not in GitHub Actions, inform user this skill is designed for CI automation.

## Guideline Path

Accept optional guideline path in prompt. Default: `docs/codeReviewGuideline.md`

Example prompts:
- `Review this PR` (uses default guideline path)
- `Review this PR with guideline at .github/REVIEW.md`

## Quick Workflow

1. Read guideline from specified path (default: `docs/codeReviewGuideline.md`)
2. Read `CLAUDE.md` for project standards (if exists)
3. Get PR context via `gh pr view` and `gh pr diff`
4. Classify issues: CRITICAL (inline) vs SUGGESTIONS (summary)
5. Deduplicate against existing unresolved comments
6. Post inline comments and summary

## Issue Classification

**CRITICAL** (inline comments):
- Bugs causing failures
- Security vulnerabilities
- Code health degradation
- Architectural violations

**SUGGESTIONS** (summary table only):
- Style inconsistencies
- Alternative approaches
- Educational comments
- Optional refactoring

## Core Principles

- Focus on actionable feedback that improves code health
- Balance critical feedback with non-blocking suggestions
- Technical facts and data override opinions
- Be direct and concise
- If code is fine, don't comment; silence means approval

## Semantic Deduplication

Before posting any comment, check existing unresolved comments:
1. Find comments at same location (path + line within +/-5)
2. If semantically similar issue exists, SKIP
3. If issue evolved, UPDATE existing comment
4. Otherwise, POST_NEW

This prevents duplicate comments on subsequent pushes.

## Detailed Workflow

See [references/workflow.md](references/workflow.md) for:
- Complete 6-phase workflow
- Semantic deduplication algorithm
- Comment reconciliation logic
- Summary comment format
