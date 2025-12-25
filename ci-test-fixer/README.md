# CI Test Fixer

Fix failing CI tests and coverage issues from GitHub Actions, then automatically commit and push.

## Features

- **Fetch CI Results**: Gets GitHub Actions workflow run failures
- **Codecov Integration**: Analyzes coverage reports and fixes coverage drops
- **Auto Fix**: Automatically fixes failing tests and coverage issues
- **Single Commit**: All fixes in one commit
- **Auto Push**: Pushes fixes automatically to PR branch

## Installation

```bash
/plugin install ci-test-fixer@geekmini-claude-code-plugins
```

Or add the marketplace:

```bash
/plugin marketplace add geekmini/claude-code-marketplace
```

## Usage

```bash
/fix-tests <pr-number>
```

**Example:**
```bash
/fix-tests 123
```

## What It Does

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  /fix-tests 123 │────▶│  Fetch CI Logs  │────▶│  Fetch Codecov  │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                         │
┌─────────────────┐     ┌─────────────────┐              │
│   Auto Push     │◀────│  Single Commit  │◀─────────────┘
└─────────────────┘     └─────────────────┘     Fix Issues
```

1. Validates PR exists and checks out the branch
2. Fetches GitHub Actions workflow run results
3. Gets failed job logs and parses test failures
4. Fetches Codecov coverage report
5. Analyzes failures and coverage drops
6. Fixes failing tests and improves coverage
7. Creates single commit with all fixes
8. Automatically pushes to remote

## Prerequisites

- **GitHub CLI** (`gh`) installed and authenticated
- Repository must use GitHub Actions for CI
- Optional: Codecov integration for coverage analysis

## Workflow

The command executes a structured workflow:

### Phase 1: Validation
- Validates PR exists and is open
- Checks out PR branch locally

### Phase 2: CI Results
- Lists recent workflow runs for the branch
- Gets failed job logs
- Parses test failures and error messages

### Phase 3: Codecov
- Fetches Codecov check run data
- Identifies files with coverage drops
- Maps uncovered lines

### Phase 4: Analysis
- Prioritizes issues (runtime errors > assertions > coverage)
- Reads source and test files
- Determines fix strategy

### Phase 5: Fix
- Fixes test errors
- Adds missing test coverage
- Ensures fixes are meaningful

### Phase 6: Commit & Push
- Single commit with descriptive message
- Auto-push to remote branch
- CI re-runs automatically

## Commit Message Format

```
fix: resolve CI test failures

Fixed tests:
- [list of fixed tests]

Coverage improvements:
- [coverage fixes if any]

Fixes CI for PR #123

Generated with [Claude Code](https://claude.com/claude-code)
```

## Troubleshooting

### No failed CI runs found
The command only works when there are actual CI failures. If all checks pass, nothing to fix.

### No Codecov report
Codecov integration is optional. If not configured, the command focuses on test failures only.

### Push fails
Check that you have write access to the branch and that branch protection rules allow direct pushes.

## Author

**GeekMini** - [https://github.com/geekmini](https://github.com/geekmini)

## License

MIT
