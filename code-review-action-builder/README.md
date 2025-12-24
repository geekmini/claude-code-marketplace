# Claude Code Review Action Builder

A Claude Code plugin that sets up intelligent, skill-based code review infrastructure for any repository.

## Features

- **Skill-Based Architecture** - Uses Claude skills for modular, maintainable review logic
- **One Command Setup** - Run `/code-review-action-builder:setup` to add everything
- **Semantic Deduplication** - Prevents duplicate comments across PR updates
- **Smart Comment Management** - Critical issues as inline comments, suggestions in summary
- **Fixed Issue Notification** - Posts reply when issues are fixed
- **Orphan Cleanup** - Deletes comments when files removed from PR
- **Works with Any Tech Stack** - Customize the guideline for your project

## Installation

### Option 1: Local Testing

```bash
claude --plugin-dir /path/to/code-review-action-builder
```

### Option 2: From Marketplace

```bash
claude plugin install code-review-action-builder@heidi-plugins
```

## Usage

Navigate to your repository and run:

```bash
/code-review-action-builder:setup
```

The command will:
1. **Detect existing setup** - Check if code review is already configured
2. **Ask about guideline** - Use existing file or create new template
3. **Create skill-based infrastructure** - All review skills with references
4. **Create GitHub Actions workflow**
5. **Create a PR with the changes**

## What Gets Created

```
your-repo/
├── .claude/
│   └── skills/
│       ├── review-pr-ci/
│       │   ├── SKILL.md              # CI automated review
│       │   └── references/
│       │       └── workflow.md       # Detailed workflow
│       ├── resolve-pr-comments/
│       │   ├── SKILL.md              # Interactive resolution
│       │   └── references/
│       │       └── workflow.md
│       └── review-and-fix/
│           ├── SKILL.md              # Local review
│           └── references/
│               └── workflow.md
├── .github/
│   └── workflows/
│       └── code-review.yml           # GitHub Actions workflow
└── docs/
    └── code-review-guideline.md      # Your customizable guideline (optional)
```

## Skills Installed

| Skill | Description |
|-------|-------------|
| `review-pr-ci` | CI-only automated review (posts GitHub comments) |
| `resolve-pr-comments` | Interactive comment resolution |
| `review-and-fix` | Local review without PR |

## Setup Requirements

After merging the PR:

1. Add `ANTHROPIC_API_KEY` secret to your repository settings
2. Customize your code review guideline for your project's standards

## How It Works

### Automatic PR Review

When a PR is opened or updated:
1. GitHub Actions triggers the workflow
2. Claude uses the `review-pr-ci` skill
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

Edit your code review guideline to include:
- Your tech stack's anti-patterns
- Project-specific conventions
- Architecture guidelines
- Testing requirements

## License

MIT
