---
name: fix-tests
description: Fix failing CI tests and coverage issues from GitHub Actions. Fetches CI results and Codecov report, fixes issues, commits and pushes.
argument-hint: "<pr-number>"
allowed-tools: ["Read", "Glob", "Grep", "Bash", "Edit", "Write", "TodoWrite"]
---

# Fix CI Tests Command

Fix failing tests and coverage issues from GitHub Actions CI, then commit and push.

## Arguments

```
$ARGUMENTS
```

**Required:** PR number must be provided.

If no PR number provided, show error:
```
Error: PR number required.

Usage: /fix-tests <pr-number>
Example: /fix-tests 123
```

## Workflow

Execute the `fix-ci-tests` skill workflow:

1. **Get PR and repo info** - Validate PR exists and get context
2. **Fetch CI results** - Get GitHub Actions workflow runs and failing jobs
3. **Fetch Codecov report** - Get coverage data and uncovered lines
4. **Analyze failures** - Parse test failures and coverage drops
5. **Fix issues** - Fix failing tests and improve coverage
6. **Commit all fixes** - Single commit with descriptive message
7. **Push to remote** - Auto-push to the PR branch

## Key Commands

```bash
# Get repo info
gh repo view --json owner,name --jq '"\(.owner.login)/\(.name)"'

# Get PR branch
gh pr view {pr_number} --json headRefName --jq '.headRefName'

# Get CI workflow runs for PR
gh run list --branch {branch} --json databaseId,status,conclusion,name --limit 10

# Get failed job logs
gh run view {run_id} --log-failed

# Get Codecov report (if available)
gh api repos/{owner}/{repo}/commits/{sha}/check-runs --jq '.check_runs[] | select(.app.slug == "codecov") | .output'
```

## Commit Message Format

```
fix: resolve CI test failures

- Fixed: [list of fixed tests]
- Coverage: [coverage improvements if any]

Fixes CI for PR #{pr_number}
```

## Constraints

- PR number is REQUIRED
- GitHub Actions only (no other CI systems)
- Focus on tests that reduce coverage
- Single commit for all fixes
- Auto-push after commit (no confirmation)
- Do NOT modify unrelated code

## Detailed Workflow

See the `fix-ci-tests` skill for complete workflow details.
