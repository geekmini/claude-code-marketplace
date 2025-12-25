# Code Review GitHub Action Factory

Set up intelligent Claude Code review infrastructure with GitHub Actions. Creates a skill-based review system with semantic deduplication and smart comment management.

## What This Plugin Does

This plugin helps you set up automated code review in your repository using Claude Code and GitHub Actions. When you run the `/setup` command, it:

1. **Creates a GitHub Actions workflow** that triggers Claude Code review on pull requests
2. **Installs review skills** in your repository's `.claude/` directory
3. **Sets up review guidelines** that Claude follows when reviewing code

## Installation

```bash
# Install via Claude Code plugin marketplace
claude plugin install code-review-github-action-factory
```

## Quick Start

1. Navigate to your repository
2. Run the setup command:
   ```
   /setup
   ```
3. Follow the prompts to configure:
   - Review guideline location (or use template)
   - Which skills to install
4. Add `ANTHROPIC_API_KEY` to your repository secrets
5. Commit and push the changes

## What Gets Created

```
your-repo/
├── .github/workflows/
│   └── claude-code-review.yml    # GitHub Actions workflow
└── .claude/
    ├── skills/
    │   ├── review-pr-ci/         # CI review skill
    │   ├── resolve-pr-comments/  # Comment resolution skill
    │   └── review-and-fix/       # Local review skill
    └── code-review-guideline.md  # Review criteria (optional)
```

## Skills Installed

### review-pr-ci

Automated code review for CI environments. Posts inline comments for critical issues and a summary comment on the PR.

**Triggers on:** PR opened, synchronized, or ready for review

**Features:**
- Semantic deduplication (won't repeat existing comments)
- Inline comments on specific lines
- Summary comment with overview
- Confidence-based filtering

### resolve-pr-comments

Interactive resolution of PR review comments. Helps address feedback from reviewers.

**Use locally:** `resolve-pr-comments` or `resolve-pr-comments 123`

**Features:**
- Fetches unresolved review threads
- Interactive fix/skip/resolve loop
- Automatic thread resolution after fixes
- Progress tracking

### review-and-fix

Local code review before creating a PR. Reviews changes without GitHub API interaction.

**Use locally:** `review my changes` or `local code review`

**Features:**
- Compares current branch to base
- Interactive fix/skip/document loop
- Tech debt documentation option
- No GitHub API required

## Configuration

### GitHub Secrets Required

Add these secrets to your repository (Settings > Secrets and variables > Actions):

| Secret | Description |
|--------|-------------|
| `ANTHROPIC_API_KEY` | Your Anthropic API key |

### Customizing Review Guidelines

The setup command can create a template guideline file, or you can point to an existing file:

```
/setup --guideline docs/review-guidelines.md
```

Guidelines control what Claude focuses on during reviews:
- Critical issues vs suggestions
- Focus areas (security, performance, etc.)
- Code style preferences

## How It Works

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   PR Created    │────▶│  GitHub Action  │────▶│  Claude Code    │
│   or Updated    │     │    Triggers     │     │    Reviews      │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                         │
                        ┌─────────────────┐              │
                        │ Inline Comments │◀─────────────┘
                        │ + PR Summary    │
                        └─────────────────┘
```

1. Developer opens or updates a pull request
2. GitHub Actions workflow triggers
3. Claude Code runs with the `review-pr-ci` skill
4. Reviews diff against guidelines and project standards
5. Posts inline comments and summary

## Workflow Configuration

The generated workflow uses these defaults:

```yaml
on:
  pull_request:
    types: [opened, synchronize, ready_for_review]

# Uses claude-sonnet-4-20250514 model
# Skips draft PRs
# Cancels in-progress reviews on new commits
```

Customize by editing `.github/workflows/claude-code-review.yml` after setup.

## Local Development

Use the local skills for development workflow:

```bash
# Review changes before PR
> review my changes

# After PR is created and reviewed
> resolve-pr-comments
```

## Troubleshooting

### Workflow not triggering

- Verify `ANTHROPIC_API_KEY` secret is set
- Check workflow file is in `.github/workflows/`
- Ensure PR is not a draft (drafts are skipped)

### Comments not appearing

- Check GitHub Actions logs for errors
- Verify Claude Code has `pull-requests: write` permission
- Ensure guideline file path is correct

### Duplicate comments

The skill uses semantic deduplication. If duplicates appear:
- Check if comments are semantically different
- Review the confidence threshold in skill config

## Author

**GeekMini** - [https://github.com/geekmini](https://github.com/geekmini)

## License

MIT
