---
description: Set up Claude Code review infrastructure in the current repository with GitHub Actions workflow and review skills
argument-hint: [optional: guideline-path]
---

# Claude Code Review Infrastructure Setup

Set up intelligent code review infrastructure using Claude Code GitHub Action with skills for automated PR review, comment resolution, and local review.

## Step 0: Pre-flight Checks

### Check Existing Setup

```bash
ls -la .claude/skills/review-pr-ci/SKILL.md .github/workflows/claude-code-review.yml 2>/dev/null
```

Build status report:

| File | Status |
|------|--------|
| `.claude/skills/review-pr-ci/SKILL.md` | ✅ Exists / ❌ Missing |
| `.claude/skills/resolve-pr-comments/SKILL.md` | ✅ Exists / ❌ Missing |
| `.claude/skills/review-and-fix/SKILL.md` | ✅ Exists / ❌ Missing |
| `.github/workflows/claude-code-review.yml` | ✅ Exists / ❌ Missing |

**If ALL core files exist** (review-pr-ci SKILL.md AND workflow):

```
Claude Code review is already set up in this repository.

What would you like to do?
```

Use AskUserQuestion with options:
- **Exit** - Keep existing setup
- **Update** - Overwrite with latest templates

If Exit: Stop with "No changes made."
If Update: Continue to Step 1.

**If files missing:** Continue to Step 1.

---

## Step 1: Gather Configuration

### 1.1: Code Review Guideline

Use AskUserQuestion:

```
Do you have an existing code review guideline file?
```

Options:
- **Yes - Use existing** - Specify path to existing guideline
- **No - Create template** - Create new guideline file

**If "Yes - Use existing":**
Ask for path, store as `GUIDELINE_PATH`.

**If "No - Create template":**
Use AskUserQuestion for location:

```
Where should the guideline file be created?
```

Options:
- `docs/code-review-guideline.md` (Recommended)
- Custom path

Store as `GUIDELINE_PATH`.

---

## Step 2: Create Branch

```bash
git checkout -b setup/claude-code-review
```

---

## Step 3: Create Directory Structure

```bash
mkdir -p .claude/skills/review-pr-ci/references
mkdir -p .claude/skills/resolve-pr-comments/references
mkdir -p .claude/skills/review-and-fix/references
mkdir -p .github/workflows
mkdir -p $(dirname "{GUIDELINE_PATH}")
```

---

## Step 4: Copy Template Files

Read template files from this plugin's `templates/` directory and write to target repository. Replace `{GUIDELINE_PATH}` placeholder with actual path.

### 4.1: review-pr-ci Skill

1. Read `${CLAUDE_PLUGIN_ROOT}/templates/skills/review-pr-ci/SKILL.md`
2. Replace `{GUIDELINE_PATH}` with actual guideline path
3. Write to `.claude/skills/review-pr-ci/SKILL.md`

4. Read `${CLAUDE_PLUGIN_ROOT}/templates/skills/review-pr-ci/references/workflow.md`
5. Replace `{GUIDELINE_PATH}` with actual guideline path
6. Write to `.claude/skills/review-pr-ci/references/workflow.md`

### 4.2: resolve-pr-comments Skill

1. Read `${CLAUDE_PLUGIN_ROOT}/templates/skills/resolve-pr-comments/SKILL.md`
2. Write to `.claude/skills/resolve-pr-comments/SKILL.md`

3. Read `${CLAUDE_PLUGIN_ROOT}/templates/skills/resolve-pr-comments/references/workflow.md`
4. Write to `.claude/skills/resolve-pr-comments/references/workflow.md`

### 4.3: review-and-fix Skill

1. Read `${CLAUDE_PLUGIN_ROOT}/templates/skills/review-and-fix/SKILL.md`
2. Replace `{GUIDELINE_PATH}` with actual guideline path
3. Write to `.claude/skills/review-and-fix/SKILL.md`

4. Read `${CLAUDE_PLUGIN_ROOT}/templates/skills/review-and-fix/references/workflow.md`
5. Replace `{GUIDELINE_PATH}` with actual guideline path
6. Write to `.claude/skills/review-and-fix/references/workflow.md`

### 4.4: GitHub Actions Workflow

1. Read `${CLAUDE_PLUGIN_ROOT}/templates/workflow/claude-code-review.yml`
2. Write to `.github/workflows/claude-code-review.yml`

### 4.5: Guideline Template (if creating new)

Only if user selected "No - Create template":

1. Read `${CLAUDE_PLUGIN_ROOT}/templates/code-review-guideline.md`
2. Write to `{GUIDELINE_PATH}`

---

## Step 5: Stage and Commit

```bash
git add -A
git commit -m "$(cat <<'EOF'
feat: add Claude Code review infrastructure

- Add review-pr-ci skill for automated CI review
- Add resolve-pr-comments skill for interactive comment resolution
- Add review-and-fix skill for local review
- Add GitHub Actions workflow for PR reviews

Features:
- Semantic deduplication prevents duplicate comments
- Smart orphan cleanup when files removed from PR
- Single summary comment per PR (updates, not duplicates)
- Fixed issue notification (user verifies and resolves)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

## Step 6: Push and Create PR

```bash
git push -u origin setup/claude-code-review
```

Create PR:

```bash
gh pr create --title "feat: add Claude Code review infrastructure" --body "$(cat <<'EOF'
## Summary

Set up intelligent Claude Code review infrastructure with:

- `review-pr-ci` skill - CI automated review with semantic deduplication
- `resolve-pr-comments` skill - Interactive comment resolution
- `review-and-fix` skill - Local review without PR
- GitHub Actions workflow for automatic PR reviews

## Features

- **Semantic Deduplication** - Prevents duplicate comments across PR updates
- **Smart Comment Management** - Critical issues as inline comments, suggestions in summary
- **Fixed Issue Notification** - Posts reply when fixed, user verifies and resolves
- **Orphan Cleanup** - Deletes comments when files removed from PR
- **Single Summary** - Updates existing summary, never duplicates

## Setup Required

After merging:
1. Add `ANTHROPIC_API_KEY` secret to repository settings
2. Customize the code review guideline for your project

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

## Step 7: Success Message

```
✅ Claude Code review infrastructure has been set up!

Created files:
- .claude/skills/review-pr-ci/SKILL.md
- .claude/skills/review-pr-ci/references/workflow.md
- .claude/skills/resolve-pr-comments/SKILL.md
- .claude/skills/resolve-pr-comments/references/workflow.md
- .claude/skills/review-and-fix/SKILL.md
- .claude/skills/review-and-fix/references/workflow.md
- .github/workflows/claude-code-review.yml
- {GUIDELINE_PATH} (if created)

PR created: [PR URL]

Next steps:
1. Add ANTHROPIC_API_KEY secret to your repository settings
2. Customize {GUIDELINE_PATH} for your project standards
3. Merge the PR to enable automated reviews
```
