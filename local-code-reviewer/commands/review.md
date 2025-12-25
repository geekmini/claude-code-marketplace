---
name: review
description: Review local code changes before creating a PR. Analyzes diff against base branch and provides interactive fix/skip/document workflow.
argument-hint: "[guideline-path]"
allowed-tools: ["Read", "Glob", "Grep", "Bash", "Edit", "Write", "AskUserQuestion", "TodoWrite"]
---

# Local Code Review Command

Review local changes and fix issues interactively before creating a PR.

## Arguments

```
$ARGUMENTS
```

Parse the arguments:
- If a path is provided, use it as the guideline file
- Otherwise, use default: `docs/codeReviewGuideline.md`

## Workflow

Execute the `review-and-fix` skill workflow:

1. **Detect base branch** - Find main/master or use `git symbolic-ref`
2. **Read guideline** - Load from specified path or default
3. **Read CLAUDE.md** - Load project standards if exists
4. **Analyze diff** - Run `git diff base...HEAD`
5. **Classify issues** - Critical > Major > Minor
6. **Interactive loop** - For each issue, ask user: Fix, Skip, or Document
7. **Commit changes** - If fixes were applied

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

For each issue, present options:
- **Fix** - Apply the proposed change
- **Skip** - Move to next issue
- **Document** - Record as tech debt in `docs/technical_debt.md`

## Progress Display

Show progress throughout:
```
Progress: X of Y issues (F fixed, S skipped, D documented)
```

## Constraints

- Do NOT post GitHub comments (local-only workflow)
- Do NOT interact with GitHub API
- Show clear progress indicators
- Process issues in severity order (Critical first)
