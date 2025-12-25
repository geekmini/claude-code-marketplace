---
name: fix-ci-tests
description: This skill should be used when fixing failing CI tests from GitHub Actions. Triggers on "fix CI tests", "fix failing tests", "fix test failures", "fix codecov", or when working with GitHub Actions test results.
---

# Fix CI Tests

Fix failing tests and coverage issues from GitHub Actions CI runs.

## Quick Workflow

1. Validate PR exists and get branch info
2. Fetch GitHub Actions workflow runs
3. Get failed job logs
4. Fetch Codecov coverage report
5. Analyze test failures and coverage drops
6. Fix issues in source code and tests
7. Single commit with all fixes
8. Auto-push to remote

## PR Validation

```bash
# Get PR info
gh pr view {pr_number} --json headRefName,headRepository,state --jq '{branch: .headRefName, state: .state}'
```

If PR is closed/merged, exit with error.

## Fetching CI Results

### Step 1: Get Latest Workflow Runs

```bash
gh run list --branch {branch} --json databaseId,status,conclusion,name,headSha --limit 10
```

Filter to failed runs: `conclusion == "failure"`

### Step 2: Get Failed Job Logs

```bash
gh run view {run_id} --log-failed
```

Parse logs to extract:
- Test file and line numbers
- Error messages
- Stack traces

## Fetching Codecov Report

### Step 1: Get Commit SHA

```bash
gh pr view {pr_number} --json headRefOid --jq '.headRefOid'
```

### Step 2: Get Codecov Check Run

```bash
gh api repos/{owner}/{repo}/commits/{sha}/check-runs \
  --jq '.check_runs[] | select(.app.slug == "codecov")'
```

### Step 3: Parse Coverage Data

Look for:
- Files with reduced coverage
- Uncovered lines in changed files
- Coverage percentage drops

## Analyzing Failures

**Test Failures:**
- Parse error messages from logs
- Identify failing test files and cases
- Understand assertion failures

**Coverage Issues:**
- Files with coverage drops
- New code without tests
- Uncovered branches/lines

## Fixing Strategy

**Priority Order:**
1. Fix test syntax/runtime errors
2. Fix assertion failures
3. Add missing test coverage
4. Fix coverage regressions

**Do NOT:**
- Modify unrelated code
- Skip tests without reason
- Reduce test quality

## Commit and Push

```bash
# Stage all changes
git add -A

# Single commit
git commit -m "fix: resolve CI test failures

- Fixed: [list fixes]
- Coverage: [improvements]

Fixes CI for PR #{pr_number}"

# Auto-push
git push origin {branch}
```

## Detailed Workflow

See [references/workflow.md](references/workflow.md) for complete step-by-step workflow.
