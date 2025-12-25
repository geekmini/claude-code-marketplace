# CI Code Review Workflow

## Arguments

```
$ARGUMENTS
```

## PR Number Resolution

Parse arguments for PR number. If not provided, auto-detect:

1. Get current branch:
   ```bash
   git branch --show-current
   ```

2. Find PR for branch:
   ```bash
   gh pr view --json number --jq '.number'
   ```

3. If no PR found:
   ```
   Error: No PR found for current branch.

   Usage:
     review-pr-ci        # Auto-detect from branch
     review-pr-ci 123    # Review PR #123
   ```

## Repository Info

```bash
gh repo view --json owner,name --jq '"\(.owner.login)/\(.name)"'
```

---

## Error Handling

**Rate Limiting (HTTP 403):** Exit gracefully with message about retry on next push.

**Permission Errors (HTTP 403/401):** Log permission needed, post summary if possible, exit.

**Network Failures:** Retry once with 5-second delay.

**PR State Changes:** If closed/merged during execution, exit gracefully.

**GraphQL Errors:** Log error, fall back to REST API if available.

**Critical vs Non-Critical:**
- Critical: Fetching PR diff, posting summary
- Non-Critical: Individual inline comments, orphan cleanup

---

## Phase 1: Code Review Analysis

### Step 1.1: Read Guidelines

1. Read `{GUIDELINE_PATH}` for review criteria
2. Reference `CLAUDE.md` for project standards (if exists)

### Step 1.2: Execute Review

1. `gh pr view` for context and description
2. `gh pr diff` for changes
3. Read source files for deeper context
4. Evaluate against guideline focus areas

### Step 1.3: Classify Issues

**CRITICAL** (inline comments):
- Bugs, security vulnerabilities
- Code health degradation
- Architectural violations
- Tech stack anti-patterns

**SUGGESTIONS** (summary only):
- Style inconsistencies
- Alternative approaches
- Educational comments
- Optional refactoring

Store: `critical_issues` and `suggestions` arrays.

---

## Phase 2: State Discovery

### Step 2.1: Fetch Existing Bot Comments

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  --jq '[.[] | select(.user.login == "github-actions[bot]" or .user.login == "claude[bot]") | {id, path, line, original_line, body}]'
```

### Step 2.2: Fetch Thread Resolution Status

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          pageInfo { hasNextPage }
          nodes {
            id
            isResolved
            comments(first: 1) {
              nodes {
                databaseId
                path
                line
              }
            }
          }
        }
      }
    }
  }
' -f owner="{owner}" -f repo="{repo}" -F pr={pr_number} \
  --jq '.data.repository.pullRequest.reviewThreads'
```

Build mapping: `comment_databaseId → {thread_id, isResolved}`

### Step 2.3: Filter to Unresolved

Keep comments where thread has `isResolved: false` or no thread found.

### Step 2.4: Get PR Diff Files

```bash
gh pr diff {pr_number} --name-only
```

---

## Phase 3: Semantic Deduplication (MANDATORY)

### Step 3.1: Find Comments at Same Location

For each critical issue at `{path, line}`:

1. Find unresolved comments where:
   - Same `path` AND
   - `line` or `original_line` within ±5 lines

2. No matches → `POST_NEW`
3. Matches found → Step 3.2

### Step 3.2: Semantic Similarity Check

Compare existing comment body with new issue:
- Same underlying code problem?
- Would fixing one fix the other?
- Same anti-pattern/bug, different wording?

**Decision:**
- SIMILAR → `SKIP`
- EVOLVED → `UPDATE`
- DIFFERENT → `POST_NEW`

### Step 3.3: Output Decision Table (MANDATORY)

```
Deduplication Analysis:
| New Issue | Line | Existing Comment | Line | Match | Decision |
|-----------|------|------------------|------|-------|----------|
| Issue A   | 26   | "Similar..."     | 24   | SIMILAR | SKIP   |
| Issue B   | 43   | (none)           | -    | -     | POST_NEW |
```

---

## Phase 4: Comment Reconciliation

### Step 4.1: Post New Issues

For `POST_NEW` decisions:
```
mcp__github_inline_comment__create_inline_comment
```

### Step 4.2: Update Evolved Issues

For `UPDATE` decisions:
```bash
gh api repos/{owner}/{repo}/pulls/comments/{id} -X PATCH -f body="<updated>"
```

### Step 4.3: Skip Duplicates

Log: "Skipped duplicate: {path}:{line}"

---

## Phase 5: State Synchronization

### Step 5.1: Notify Fixed Issues

For each fixed issue (not in current findings):
```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  -X POST \
  -f body="✅ This issue appears to be addressed. Please verify and resolve this thread." \
  -F in_reply_to={comment_id}
```

**Do NOT auto-resolve** - user verifies.

### Step 5.2: Delete Orphaned Comments

For comments on files no longer in diff:
```bash
gh api repos/{owner}/{repo}/pulls/comments/{id} -X DELETE
```

---

## Phase 6: Summary Comment

### Step 6.1: Find Existing Summary

```bash
gh api repos/{owner}/{repo}/issues/{pr_number}/comments \
  --jq '[.[] | select((.user.login == "github-actions[bot]" or .user.login == "claude[bot]") and (.body | contains("## Code Review Summary"))) | .id] | first'
```

### Step 6.2: Update or Create

**Format:**

```markdown
## Code Review Summary

### Overview
<Brief description>

### Critical Issues
**{N} critical issue(s) posted as inline comments.**

### Suggestions

| File | Line | Issue |
|------|------|-------|
| `path` | 42 | Description |

### What's Good
<Positive aspects>

### Review Actions
- Critical posted: {n}
- Duplicates skipped: {n}
- Fixed notified: {n}
- Orphans deleted: {n}

### Files Reviewed

| File | Status |
|------|--------|
| `path` | Summary |

---
**Review Cost**: $X.XX

Generated with [Claude Code](https://claude.com/claude-code)
```

---

## Constraints

- CI-only: Must run in CI environment
- Critical issues only as inline comments
- Semantic deduplication is MANDATORY
- Do NOT auto-resolve threads
- One summary comment per PR
