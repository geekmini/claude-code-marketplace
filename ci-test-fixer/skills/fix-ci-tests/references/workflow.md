# Fix CI Tests Workflow

## Arguments

```
$ARGUMENTS
```

## Phase 1: Validation

### Step 1.1: Parse PR Number

PR number is required. If not provided:
```
Error: PR number required.

Usage: /fix-tests <pr-number>
Example: /fix-tests 123
```

### Step 1.2: Get Repository Info

```bash
gh repo view --json owner,name --jq '"\(.owner.login)/\(.name)"'
```

Store as `{owner}/{repo}`.

### Step 1.3: Validate PR Exists

```bash
gh pr view {pr_number} --json headRefName,headRefOid,state \
  --jq '{branch: .headRefName, sha: .headRefOid, state: .state}'
```

**If state is "CLOSED" or "MERGED":**
```
Error: PR #{pr_number} is {state}. Cannot fix tests on closed/merged PR.
```

### Step 1.4: Checkout PR Branch

```bash
git fetch origin {branch}
git checkout {branch}
git pull origin {branch}
```

---

## Phase 2: Fetch GitHub Actions Results

### Step 2.1: List Workflow Runs

```bash
gh run list --branch {branch} --json databaseId,status,conclusion,name,headSha --limit 10
```

### Step 2.2: Filter Failed Runs

From the list, find runs where:
- `conclusion == "failure"`
- `headSha` matches current PR head

### Step 2.3: Get Failed Job Details

For each failed run:
```bash
gh run view {run_id} --json jobs --jq '.jobs[] | select(.conclusion == "failure") | {name, steps: [.steps[] | select(.conclusion == "failure")]}'
```

### Step 2.4: Get Failed Logs

```bash
gh run view {run_id} --log-failed
```

**Parse logs for:**
- Test framework output (Jest, pytest, etc.)
- Error messages and stack traces
- File paths and line numbers
- Assertion failures

Store as `failed_tests` array:
```json
[
  {
    "file": "src/utils.test.js",
    "test": "should handle edge case",
    "error": "Expected 5 but got 4",
    "line": 42
  }
]
```

---

## Phase 3: Fetch Codecov Report

### Step 3.1: Get Check Runs

```bash
gh api repos/{owner}/{repo}/commits/{sha}/check-runs \
  --jq '.check_runs[] | select(.app.slug == "codecov" or .name | contains("codecov"))'
```

### Step 3.2: Parse Coverage Summary

Extract from check run output:
- Overall coverage percentage
- Coverage change (+ or -)
- Files with coverage drops

### Step 3.3: Get Detailed Coverage (if available)

```bash
gh api repos/{owner}/{repo}/commits/{sha}/status \
  --jq '.statuses[] | select(.context | contains("codecov"))'
```

### Step 3.4: Identify Coverage Issues

Store as `coverage_issues` array:
```json
[
  {
    "file": "src/newFeature.js",
    "coverage": "45%",
    "uncovered_lines": [10, 15, 20-25],
    "issue": "New code without tests"
  }
]
```

---

## Phase 4: Analysis

### Step 4.1: Prioritize Issues

**Priority order:**
1. **Critical:** Test runtime errors (syntax, import failures)
2. **High:** Assertion failures in existing tests
3. **Medium:** Coverage drops in changed files
4. **Low:** Coverage improvements for new code

### Step 4.2: Read Source Files

For each failed test:
```bash
# Read test file
cat {test_file}

# Read source file being tested
cat {source_file}
```

### Step 4.3: Understand Failures

For each failure:
- What is the test expecting?
- What is the actual behavior?
- Is it a test bug or source bug?
- What code change caused the regression?

---

## Phase 5: Fix Issues

### Step 5.1: Fix Test Errors

For each failed test:
1. Read the test file
2. Read the source file
3. Determine if test or source needs fixing
4. Apply the fix using Edit tool

### Step 5.2: Fix Coverage Issues

For files with coverage drops:
1. Identify uncovered lines/branches
2. Add tests for uncovered code
3. Ensure tests are meaningful (not just coverage padding)

### Step 5.3: Run Tests Locally (Optional)

If test command is known:
```bash
npm test
# or
pytest
# or
go test ./...
```

Verify fixes work before committing.

---

## Phase 6: Commit

### Step 6.1: Stage All Changes

```bash
git add -A
```

### Step 6.2: Create Commit

```bash
git commit -m "$(cat <<'EOF'
fix: resolve CI test failures

Fixed tests:
- [list each fixed test]

Coverage improvements:
- [list coverage fixes if any]

Fixes CI for PR #{pr_number}

Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**Single commit for all fixes** - do not create multiple commits.

---

## Phase 7: Push

### Step 7.1: Push to Remote

```bash
git push origin {branch}
```

**Auto-push** - no confirmation needed.

### Step 7.2: Confirmation

After push:
```
Successfully pushed fixes to branch '{branch}'.

Summary:
- Tests fixed: {n}
- Coverage issues addressed: {n}
- Files modified: {n}

CI will re-run automatically. Check PR #{pr_number} for results.
```

---

## Error Handling

**No failed CI runs found:**
```
No failed CI runs found for PR #{pr_number}.
All checks are passing!
```

**No Codecov report:**
```
No Codecov report found. Proceeding with test failures only.
```

**Cannot determine test framework:**
```
Warning: Could not identify test framework. Analyzing logs directly.
```

**Push fails:**
```
Error: Push failed. Please check branch permissions and try again.
```

---

## Constraints

- PR number is REQUIRED (no auto-detection)
- GitHub Actions only
- Focus on tests that reduce coverage
- Single commit for all fixes
- Auto-push (no confirmation)
- Do NOT modify unrelated code
- Do NOT skip/disable tests without good reason
