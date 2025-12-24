---
description: Set up Claude Code review infrastructure in the current repository. Creates skills, workflow, and optionally a template guideline.
---

# Claude Code Review Setup

This command sets up intelligent code review infrastructure for your repository using skills.

## Step 0: Check Existing Setup

First, check if Claude Code review infrastructure already exists:

```bash
ls -la .claude/skills/review-pr-ci/SKILL.md .github/workflows/code-review.yml 2>/dev/null
```

**Build a status report:**

| File | Status |
|------|--------|
| `.claude/skills/review-pr-ci/SKILL.md` | ✅ Exists / ❌ Missing |
| `.claude/skills/resolve-pr-comments/SKILL.md` | ✅ Exists / ❌ Missing |
| `.claude/skills/review-and-fix/SKILL.md` | ✅ Exists / ❌ Missing |
| `.github/workflows/code-review.yml` | ✅ Exists / ❌ Missing |

**If ALL core files exist** (review-pr-ci SKILL.md AND code-review.yml):

Show status and ask user:

```
Claude Code review is already set up in this repository.

Existing files:
- .claude/skills/review-pr-ci/SKILL.md ✅
- .claude/skills/resolve-pr-comments/SKILL.md ✅
- .claude/skills/review-and-fix/SKILL.md ✅
- .github/workflows/code-review.yml ✅

What would you like to do?
```

**Options:**
- **Exit** - Keep existing setup, no changes
- **Update** - Overwrite all files with latest templates
- **Show diff** - Compare existing files with templates

**If user selects Exit:** Stop here with message "No changes made."

**If user selects Show diff:** Read each existing file and show differences from templates, then ask again.

**If user selects Update:** Continue to Step 1 (will overwrite files).

**If SOME files are missing:** Show what exists vs missing and continue to Step 1.

**If NO files exist:** Continue to Step 1 (fresh setup).

---

## Step 1: Gather Information

### 1.1: Ask about code review guideline

Ask the user using `AskUserQuestion`:

```
Do you have an existing code review guideline file?
```

**Options:**
- **Yes - Use existing file** - I'll specify the path to my existing guideline
- **No - Create new template** - Create a new template guideline for me

**If user selects "Yes - Use existing file":**
Ask for the path to their existing guideline file.
Store as `GUIDELINE_PATH`.

**If user selects "No - Create new template":**
Ask where to place the new guideline:

```
Where should the code review guideline file be located?
```

**Options:**
- `docs/code-review-guideline.md` (Recommended) - Standard location
- Custom path - Let me specify a different path

Store the path as `GUIDELINE_PATH` (default: `docs/code-review-guideline.md`).

## Step 2: Create Branch

Create a new branch for the setup:

```bash
git checkout -b setup/claude-code-review
```

## Step 3: Create Directory Structure

Create the necessary directories:

```bash
mkdir -p .claude/skills/review-pr-ci/references
mkdir -p .claude/skills/resolve-pr-comments/references
mkdir -p .claude/skills/review-and-fix/references
mkdir -p .github/workflows
```

Also create the directory for the guideline file (if creating new):

```bash
mkdir -p $(dirname {GUIDELINE_PATH})
```

## Step 4: Create Files

**IMPORTANT:** Read skill files from this plugin's `skills/` directory and copy them to the target repository. Replace `{GUIDELINE_PATH}` with the actual path from Step 1 in all files.

### 4.1: Copy review-pr-ci skill

1. Read `../skills/review-pr-ci/SKILL.md` (relative to this command file)
2. Replace all occurrences of `{GUIDELINE_PATH}` with the actual guideline path
3. Write to `.claude/skills/review-pr-ci/SKILL.md`

4. Read `../skills/review-pr-ci/references/workflow.md`
5. Replace all occurrences of `{GUIDELINE_PATH}` with the actual guideline path
6. Write to `.claude/skills/review-pr-ci/references/workflow.md`

### 4.2: Copy resolve-pr-comments skill

1. Read `../skills/resolve-pr-comments/SKILL.md`
2. Write to `.claude/skills/resolve-pr-comments/SKILL.md`

3. Read `../skills/resolve-pr-comments/references/workflow.md`
4. Write to `.claude/skills/resolve-pr-comments/references/workflow.md`

### 4.3: Copy review-and-fix skill

1. Read `../skills/review-and-fix/SKILL.md`
2. Replace all occurrences of `{GUIDELINE_PATH}` with the actual guideline path
3. Write to `.claude/skills/review-and-fix/SKILL.md`

4. Read `../skills/review-and-fix/references/workflow.md`
5. Replace all occurrences of `{GUIDELINE_PATH}` with the actual guideline path
6. Write to `.claude/skills/review-and-fix/references/workflow.md`

### 4.4: Create GitHub Actions workflow

Create `.github/workflows/code-review.yml`:

```yaml
name: Claude Code Review

# AI-powered code review on pull requests using Claude Code.
#
# Triggers: PR opened, synchronized (new commits pushed), or ready_for_review
#
# Requirements:
# - ANTHROPIC_API_KEY secret must be configured

on:
  pull_request:
    types: [opened, synchronize, ready_for_review]

concurrency:
  group: claude-review-${{ github.event.pull_request.number }}
  cancel-in-progress: true

jobs:
  claude-review:
    runs-on: ubuntu-latest
    if: github.event.pull_request.draft == false
    permissions:
      contents: read
      pull-requests: write
      issues: read
      id-token: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Run Claude Code Review
        id: claude-code-review
        uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Review PR #${{ github.event.pull_request.number }} in ${{ github.repository }}.

            Use the review-pr-ci skill to perform the review.

          claude_args: |
            --model claude-opus-4-5 --allowed-tools "Skill,Bash(gh api:*),Bash(gh issue view:*),Bash(gh search:*),Bash(gh issue list:*),Bash(gh pr comment:*),Bash(gh pr diff:*),Bash(gh pr view:*),Bash(gh pr list:*),Bash(gh repo view:*),mcp__github_inline_comment__create_inline_comment,Read,Grep,Glob"
```

### 4.5: Create Template Guideline (if user chose to create new)

**Only create this file if user selected "No - Create new template" in Step 1.**

Create at `{GUIDELINE_PATH}`:

```markdown
# Code Review Guidelines

## Core Principles

- Focus on actionable feedback that improves code health
- Balance critical feedback with non-blocking suggestions (use "Nit:" prefix)
- Technical facts and data override personal opinions
- Be direct and concise
- If code is fine, don't comment on it; silence means approval

## Review Process

1. **Understand the Change**
   - Read the PR description
   - Understand what problem this code solves
   - Consider the broader context

2. **Evaluate Code Health**
   - Does this make the system easier or harder to maintain?
   - Is the code more readable than before?
   - Does it follow established patterns?
   - Are there obvious bugs or edge cases not handled?

## Focus Areas

### Design & Architecture
- Does the code fit with the overall system design?
- Are there better architectural approaches?
- Is separation of concerns followed?

### Functionality
- Does the code do what the author intended?
- Are there edge cases not handled?
- Is error handling appropriate?

### Complexity
- Can other developers understand this code quickly?
- Is the code over-engineered?
- Should any code be broken into smaller functions?

### Tests
- Are there appropriate tests for new functionality?
- Do tests cover error cases and edge cases?

### Naming & Style
- Are variables, functions, and classes named clearly?
- Does code follow existing patterns in the codebase?

## Critical vs Suggestions

**Critical (must fix):**
- Bugs that will cause failures
- Security vulnerabilities
- Code that worsens code health
- Violations of architectural principles

**Suggestions (prefix with "Nit:"):**
- Minor style inconsistencies
- Alternative approaches
- Educational comments
- Optional refactoring ideas
```

## Step 5: Stage and Commit

```bash
git add -A
git commit -m "feat: add Claude Code review infrastructure (skill-based)

- Add review-pr-ci skill for CI automated review
- Add resolve-pr-comments skill for interactive comment resolution
- Add review-and-fix skill for local review without PR
- Add GitHub Actions workflow for PR reviews

Features:
- Semantic deduplication prevents duplicate comments
- Smart orphan cleanup when files removed
- Single summary comment per PR (updates, not duplicates)
- Fixed issue notification (user verifies and resolves)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## Step 6: Push and Create PR

```bash
git push -u origin setup/claude-code-review
```

Create the PR:

```bash
gh pr create --title "feat: add Claude Code review infrastructure" --body "$(cat <<'EOF'
## Summary

Set up intelligent Claude Code review infrastructure with skills:

- `review-pr-ci` skill - CI automated review with semantic deduplication
- `resolve-pr-comments` skill - Interactive comment resolution
- `review-and-fix` skill - Local review without PR
- GitHub Actions workflow for automatic PR reviews

## Features

- **Semantic Deduplication** - Prevents duplicate comments across PR updates
- **Smart Comment Management** - Critical issues as inline, suggestions in summary
- **Fixed Issue Notification** - Posts reply when fixed, user verifies and resolves
- **Orphan Cleanup** - Deletes comments when files removed from PR
- **Single Summary** - Updates existing summary, never duplicates

## Setup Required

1. Add `ANTHROPIC_API_KEY` secret to repository settings
2. Customize `{GUIDELINE_PATH}` for your project's standards

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

## Step 7: Confirm Success

Show the user:

```
✅ Claude Code review infrastructure has been set up!

Created files:
- .claude/skills/review-pr-ci/SKILL.md
- .claude/skills/review-pr-ci/references/workflow.md
- .claude/skills/resolve-pr-comments/SKILL.md
- .claude/skills/resolve-pr-comments/references/workflow.md
- .claude/skills/review-and-fix/SKILL.md
- .claude/skills/review-and-fix/references/workflow.md
- .github/workflows/code-review.yml
- {GUIDELINE_PATH} (if created)

PR created: [show PR URL]

Next steps:
1. Add ANTHROPIC_API_KEY secret to your repository
2. Customize {GUIDELINE_PATH} for your project
3. Merge the PR to enable automated reviews
```
