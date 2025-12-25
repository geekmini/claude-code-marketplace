# Code Review Action Builder

A Claude Code plugin that sets up intelligent, skill-based code review infrastructure for any repository.

## Installation

### 1. Add the Marketplace

```bash
/plugin marketplace add https://github.com/geekmini/claude-code-marketplace.git
```

### 2. Install the Plugin

```bash
/plugin install geekmini-claude-code-plugins@code-review-action-builder
```

## Usage

Navigate to your repository and run:

```bash
/code-review-action-builder:setup
```

This will create GitHub Actions workflow and review skills, then open a PR with the changes.

## Post-Setup

After merging the PR, add `ANTHROPIC_API_KEY` secret to your repository settings.

## License

MIT
