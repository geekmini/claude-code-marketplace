# Claude Code Review Builder

A Claude Code plugin that sets up intelligent code review infrastructure for any repository.

## Features

- **One Command Setup** - Run `/code-review:setup` to add everything
- **Semantic Deduplication** - Prevents duplicate comments across PR updates
- **Smart Comment Management** - Critical issues as inline comments, suggestions in summary
- **Fixed Issue Notification** - Posts reply when issues are fixed
- **Orphan Cleanup** - Deletes comments when files removed from PR
- **Works with Any Tech Stack** - Customize the guideline for your project

## Installation

### Option 1: Local Testing

```bash
claude --plugin-dir /path/to/claude-review-builder
```

### Option 2: From Marketplace (Coming Soon)

```bash
claude plugin install code-review
```

## Usage

Navigate to your repository and run:

```bash
/code-review:setup
```

The command will:
1. Ask where to place your code review guideline
2. Create all necessary files
3. Create a PR with the changes

## What Gets Created

```
your-repo/
├── .claude/
│   ├── commands/
│   │   ├── review-pr-ci.md      # CI automated review
│   │   ├── resolve-pr-comments.md # Interactive resolution
│   │   └── review-and-fix.md    # Local review
│   └── prompts/
│       └── review-pr.md         # Core review prompt
├── .github/
│   └── workflows/
│       └── code-review.yml      # GitHub Actions workflow
└── docs/
    └── code-review-guideline.md # Your customizable guideline
```

## Commands Installed

| Command | Description |
|---------|-------------|
| `/review-pr-ci` | CI-only automated review (posts GitHub comments) |
| `/resolve-pr-comments` | Interactive comment resolution |
| `/review-and-fix` | Local review without PR |

## Setup Requirements

After merging the PR:

1. Add `ANTHROPIC_API_KEY` secret to your repository settings
2. Customize the code review guideline for your project's standards

## How It Works

### Automatic PR Review

When a PR is opened or updated:
1. GitHub Actions triggers the workflow
2. Claude analyzes the changes against your guideline
3. Critical issues → Inline comments
4. Suggestions → Summary table
5. Semantic deduplication prevents duplicate comments

### Semantic Deduplication

On subsequent pushes:
- Compares new findings against existing unresolved comments
- Uses ±5 line tolerance (code shifts between pushes)
- LLM-based similarity detection
- Only posts truly new issues

### Fixed Issue Handling

When you fix an issue:
- Bot posts a reply: "✅ This issue appears to be addressed"
- You verify the fix and click "Resolve conversation"
- Bot does NOT auto-resolve (you maintain control)

## Customization

Edit your code review guideline (`docs/code-review-guideline.md`) to include:
- Your tech stack's anti-patterns
- Project-specific conventions
- Architecture guidelines
- Testing requirements

## License

MIT
