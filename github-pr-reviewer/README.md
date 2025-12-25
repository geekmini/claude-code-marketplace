# GitHub PR Reviewer

Automated PR code review for GitHub Actions with semantic deduplication and inline comments.

## Features

- **Inline Comments**: Posts critical issues directly on relevant code lines
- **Semantic Deduplication**: Won't repeat existing comments on subsequent pushes
- **Summary Comment**: Overview with suggestions table and review stats
- **Smart Classification**: Separates critical issues from minor suggestions

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
          plugin_marketplaces: |
            geekmini/claude-code-marketplace
          plugins: |
            github-pr-reviewer@geekmini-claude-code-plugins
          prompt: |
            Review this PR using the review-pr-ci skill.
          claude_args: |
            --model claude-sonnet-4-20250514
```

### Required Secrets

Add to your repository (Settings > Secrets and variables > Actions):

| Secret | Description |
|--------|-------------|
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
4. Reviews diff against code quality standards
5. Posts inline comments for critical issues
6. Posts summary comment with suggestions

## Issue Classification

**Critical Issues** (posted as inline comments):
- Bugs that will cause failures
- Security vulnerabilities
- Code health degradation
- Architectural violations

**Suggestions** (summary table only):
- Style inconsistencies
- Alternative approaches
- Educational comments
- Optional refactoring

## Semantic Deduplication

The plugin intelligently avoids duplicate comments:

1. Checks existing unresolved comments on the PR
2. Compares new issues against existing ones
3. Skips if semantically similar issue already exists
4. Updates if issue has evolved
5. Posts only genuinely new issues

This prevents comment spam on subsequent pushes.

## Customizing Review Standards

Add a `CLAUDE.md` file to your repository root with project-specific guidelines:

```markdown
# Project Standards

## Code Style
- Use TypeScript strict mode
- Prefer functional components

## Architecture
- Follow hexagonal architecture
- Keep business logic in domain layer

## Testing
- Minimum 80% coverage for new code
- Integration tests for API endpoints
```

The reviewer will use these guidelines when evaluating code.

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
