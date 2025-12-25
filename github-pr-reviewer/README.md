# GitHub PR Reviewer

Automated PR code review for GitHub Actions with semantic deduplication and inline comments.

## Features

- **Inline Comments**: Posts critical issues directly on relevant code lines
- **State-Based Deduplication**: Tracks posted issues in summary, prevents duplicates across pushes
- **Summary Comment**: Overview with nits table, review stats, and hidden state metadata
- **Smart Classification**: Critical/Suggestions get inline comments, Nits go to summary only
- **Custom Guidelines**: Use your own review guideline file

## Installation

Install via Claude Code:

```bash
/plugin install github-pr-reviewer@geekmini-claude-code-plugins
```

Or add the marketplace:

```bash
/plugin marketplace add geekmini/claude-code-marketplace
```

## GitHub Action Setup

Add this workflow to your repository at `.github/workflows/claude-code-review.yml`:

```yaml
name: Claude Code Review

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
        uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          plugin_marketplaces: geekmini/claude-code-marketplace
          plugins: github-pr-reviewer@geekmini-claude-code-plugins
          prompt: Review this PR using the review-pr-ci skill.
          claude_args: |
            --model claude-opus-4-5 --allowed-tools "Skill,Bash(gh api:*),Bash(gh issue view:*),Bash(gh search:*),Bash(gh issue list:*),Bash(gh pr comment:*),Bash(gh pr diff:*),Bash(gh pr view:*),Bash(gh pr list:*),Bash(gh repo view:*),mcp__github_inline_comment__create_inline_comment,Read,Grep,Glob"
```

### Custom Guideline Path

By default, the skill reads guidelines from `docs/codeReviewGuideline.md`. To use a custom path:

```yaml
          prompt: |
            Review this PR using the review-pr-ci skill with guideline at .github/CODE_REVIEW.md
```

### Required Secrets

Add to your repository (Settings > Secrets and variables > Actions):

| Secret              | Description            |
| ------------------- | ---------------------- |
| `ANTHROPIC_API_KEY` | Your Anthropic API key |

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
4. **Fetches existing summary to read INLINE_STATE** (deduplication state)
5. Reviews diff against code quality standards
6. Compares findings against state - skips already-posted issues
7. Posts NEW inline comments for critical issues and suggestions
8. Updates summary comment with nits and new INLINE_STATE

## Issue Classification

**Critical Issues** (inline comments):
- Bugs that will cause failures
- Security vulnerabilities
- Code health degradation
- Architectural violations

**Suggestions** (inline comments):
- Performance issues
- Maintainability concerns
- Missing error handling
- Actionable improvements

**Nits** (summary table only - no inline comments):
- Style inconsistencies
- Alternative approaches
- Educational comments
- Optional refactoring

## State-Based Deduplication

The plugin uses the summary comment as persistent state to avoid duplicate comments across pushes:

1. Fetches existing summary comment (titled `## claude-code-review-summary`)
2. Parses hidden `INLINE_STATE` metadata containing all previously posted issues
3. Generates a hash for each new finding (based on path + issue description)
4. Compares against state - skips if issue already posted (even if line numbers changed)
5. Posts only genuinely new issues
6. Updates summary with new state

This prevents comment spam even when line numbers drift between pushes.

## Customizing Review Standards

Create a guideline file at `docs/codeReviewGuideline.md` (or custom path):

```markdown
# Code Review Guidelines

## Critical Issues (Must Fix)
- Bugs that will cause failures
- Security vulnerabilities
- Architectural violations

## Suggestions (Nice to Have)
- Style inconsistencies
- Alternative approaches

## Focus Areas
- Error handling
- Performance
- Security
```

The reviewer reads this file and uses it to evaluate code changes. You can also add a `CLAUDE.md` at repo root for general project standards.

## Troubleshooting

### Workflow not triggering

- Verify `ANTHROPIC_API_KEY` secret is set
- Check workflow file is in `.github/workflows/`
- Ensure PR is not a draft (drafts are skipped)

### Comments not appearing

- Check GitHub Actions logs for errors
- Verify Claude Code has `pull-requests: write` permission
- Check rate limits on Anthropic API

### Too many comments

- Add `CLAUDE.md` with specific focus areas
- Adjust the prompt to focus on critical issues only

## Author

**GeekMini** - [https://github.com/geekmini](https://github.com/geekmini)

## License

MIT
