---
name: review-and-fix
description: This skill should be used when reviewing local code changes before creating a PR. Triggers on "review my changes", "local code review", "review before PR", "check my code", or when reviewing changes that haven't been pushed yet.
---

# Local Code Review

Review local changes and fix issues interactively before creating a PR. Uses same classification as CI review for consistency.

## Guideline Path

Accept optional guideline path in prompt. Default: `docs/codeReviewGuideline.md`

Example:
- `review my changes` (uses default)
- `review my changes with guideline at .github/REVIEW.md`

## Quick Workflow

1. Detect base branch (main/master)
2. Read guideline from specified path (default: `docs/codeReviewGuideline.md`)
3. Read `CLAUDE.md` for project standards (if exists)
4. Analyze diff using `git diff base...HEAD`
5. Classify and sort: Critical > Major > Minor
6. Interactive loop: Fix, Skip, or Document each issue
7. Commit changes if fixes applied

## Issue Classification

**CRITICAL** (must fix):
- Bugs causing failures
- Security vulnerabilities
- Code health degradation
- Architectural violations

**MAJOR** (strong suggestions):
- Performance issues
- Poor maintainability

**MINOR** (nits):
- Style inconsistencies
- Alternative approaches

## User Options

For each issue:
- **Fix** - Apply the change
- **Skip** - Move to next
- **Document** - Record as tech debt in `docs/technical_debt.md`

## Constraints

- Do NOT post GitHub comments (local-only)
- Do NOT interact with GitHub API
- Show clear progress indicators

## Detailed Workflow

See [references/workflow.md](references/workflow.md) for complete review phases and interactive fix loop details.
