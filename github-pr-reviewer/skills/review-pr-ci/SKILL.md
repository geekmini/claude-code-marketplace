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
3. **Fetch existing summary and parse INLINE_STATE** (critical for deduplication)
4. Get PR context via `gh pr view` and `gh pr diff`
5. Classify issues: CRITICAL/SUGGESTIONS (inline) vs NITS (summary only)
6. Generate issueHash for each finding and compare against INLINE_STATE
7. Post only NEW inline comments (skip duplicates)
8. Update summary with new INLINE_STATE

## STRICT RULE: One Summary Per PR (State Tracker)

**There must be exactly ONE summary comment per PR. The summary serves as persistent state across CI runs.**

- ALWAYS search for existing summary comment FIRST (title: `claude-code-review-summary`)
- If summary exists → READ its inline state, then UPDATE it (PATCH)
- If no summary exists → CREATE it (POST)
- NEVER create a new summary if one already exists
- The summary contains hidden metadata tracking all posted inline comments

## Issue Classification

**CRITICAL** (inline comments):
- Bugs causing failures
- Security vulnerabilities
- Code health degradation
- Architectural violations

**SUGGESTIONS** (inline comments):
- Performance issues
- Maintainability concerns
- Missing error handling
- Actionable improvements

**NITS** (summary table only - NO inline comments):
- Style inconsistencies
- Alternative approaches
- Educational comments
- Optional refactoring
- Naming preferences

## Core Principles

- Focus on actionable feedback that improves code health
- Balance critical feedback with non-blocking suggestions
- Technical facts and data override opinions
- Be direct and concise
- If code is fine, don't comment; silence means approval

## State-Based Deduplication

Before posting any comment, read state from existing summary:
1. Fetch existing summary comment (contains `INLINE_STATE` metadata)
2. Parse the hidden `INLINE_STATE` JSON to get list of already-posted issues
3. Compare new findings by `path` + `issueHash` (NOT by line number)
4. If issue already posted → SKIP (even if line number changed)
5. If truly new issue → POST_NEW and add to state

This prevents duplicate comments across pushes, even when line numbers drift.

## Detailed Workflow

See [references/workflow.md](references/workflow.md) for:
- Complete 6-phase workflow
- Semantic deduplication algorithm
- Comment reconciliation logic
- Summary comment format
