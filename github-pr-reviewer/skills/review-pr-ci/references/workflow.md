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

### Step 1.1: Read Guideline

Parse guideline path from prompt. Default: `docs/codeReviewGuideline.md`

```bash
# Check if guideline file exists
cat docs/codeReviewGuideline.md 2>/dev/null || echo "No guideline file found"
```

If guideline file exists, use it as primary review criteria.
Also reference `CLAUDE.md` for project standards (if exists).

### Step 1.2: Execute Review

1. `gh pr view` for context and description
2. `gh pr diff` for changes
3. Read source files for deeper context
4. Evaluate against code quality standards

### Step 1.3: Classify Issues

**CRITICAL** (inline comments):
- Bugs, security vulnerabilities
- Code health degradation
- Architectural violations
- Tech stack anti-patterns

**SUGGESTIONS** (inline comments):
- Performance issues
- Maintainability concerns
- Missing error handling
- Actionable improvements

**NITS** (summary table only - NO inline comments):
- Style inconsistencies
- Alternative approaches
- Educational comments
- Optional refactoring
- Naming preferences

Store: `critical_issues`, `suggestions`, and `nits` arrays.

---

## Phase 2: State Discovery (Summary-Based)

### Step 2.1: Fetch Existing Summary (CRITICAL - DO THIS FIRST)

```bash
gh api repos/{owner}/{repo}/issues/{pr_number}/comments \
  --jq '[.[] | select((.user.login == "github-actions[bot]" or .user.login == "claude[bot]") and (.body | contains("## claude-code-review-summary"))) | {id, body}] | first'
```

**Parse the result:**
- If result is `null` or empty → No existing summary, `INLINE_STATE = []`
- If result has a body → Extract `INLINE_STATE` from the hidden comment block

### Step 2.2: Parse INLINE_STATE from Summary

If summary exists, extract the JSON between `INLINE_STATE_START` and `INLINE_STATE_END`:

```
The summary body contains:
<!-- INLINE_STATE_START
[{"path":"src/foo.ts","issueHash":"abc123","line":42,"commentId":123456},...]
INLINE_STATE_END -->
```

Parse this JSON array into `existing_issues` list. Each entry has:
- `path`: file path
- `issueHash`: MD5/short hash of the issue description (first 8 chars)
- `line`: line number when posted (for reference only, not for matching)
- `commentId`: GitHub comment ID (for potential updates)

**If no INLINE_STATE block found or parsing fails:** `existing_issues = []`

### Step 2.3: Get PR Diff Files

```bash
gh pr diff {pr_number} --name-only
```

### Step 2.4: Fetch Resolved Threads (Optional Cleanup)

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            isResolved
            comments(first: 1) {
              nodes { databaseId path }
            }
          }
        }
      }
    }
  }
' -f owner="{owner}" -f repo="{repo}" -F pr={pr_number}
```

Use this to identify resolved threads for cleanup from state.

---

## Phase 3: State-Based Deduplication (MANDATORY)

### Step 3.1: Generate Issue Hash for Each Finding

For each critical issue or suggestion, generate a unique hash:

```
issueHash = first 8 characters of MD5(path + ":" + normalized_issue_description)
```

**Normalize issue description:**
- Lowercase
- Remove line numbers from description
- Remove extra whitespace
- Keep only the core issue (e.g., "missing null check", "potential sql injection")

Example:
- Path: `src/auth.ts`
- Issue: "Missing null check on user input"
- Normalized: `src/auth.ts:missing null check on user input`
- Hash: `a1b2c3d4`

### Step 3.2: Compare Against Existing State

For each new finding with `{path, issueHash}`:

1. Search `existing_issues` (from Phase 2) for matching `path` AND `issueHash`
2. If match found → `SKIP` (already posted, even if line changed)
3. If no match → `POST_NEW`

**Important:** Do NOT compare by line number. Line numbers drift between pushes.

### Step 3.3: Output Decision Table (MANDATORY)

```
Deduplication Analysis:
| New Issue | Path | Hash | Existing | Decision |
| --------- | ---- | ---- | -------- | -------- |
| null check | src/auth.ts | a1b2c3d4 | YES | SKIP |
| sql inject | src/db.ts | e5f6g7h8 | NO | POST_NEW |
```

### Step 3.4: Build Post Queue

Create `to_post` array containing only `POST_NEW` decisions:
```json
[{"path": "src/db.ts", "line": 42, "issueHash": "e5f6g7h8", "body": "...", "severity": "CRITICAL"}]
```

---

## Phase 4: Comment Reconciliation

### Step 4.1: Post New Issues and Track IDs

For each item in `to_post` queue, post and capture the comment ID:

```bash
# Post inline comment and capture response
response=$(gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  -X POST \
  -f body="**{severity}**: {issue_description}" \
  -f commit_id="{commit_sha}" \
  -f path="{path}" \
  -F line={line} \
  -f side="RIGHT")

# Extract comment ID from response
comment_id=$(echo "$response" | jq '.id')
```

**Track each posted comment:**
```json
{"path": "src/db.ts", "issueHash": "e5f6g7h8", "line": 42, "commentId": 123456}
```

Add to `new_posted_issues` array.

### Step 4.2: Merge State

Combine existing state with newly posted:
```
final_state = existing_issues + new_posted_issues
```

Remove entries for:
- Files no longer in diff (orphaned)
- Threads that were resolved by user

### Step 4.3: Log Actions

```
Posted: {n} new inline comments
Skipped: {n} duplicates (already in state)
Removed: {n} orphaned/resolved from state
```

---

## Phase 5: Optional Cleanup

### Step 5.1: Notify Fixed Issues (Optional)

If an issue in `existing_issues` is no longer detected in current findings AND the file still exists in diff:
```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  -X POST \
  -f body="✅ This issue appears to be addressed. Please verify and resolve this thread." \
  -F in_reply_to={comment_id}
```

**Do NOT auto-resolve** - user verifies.

### Step 5.2: Orphan Handling

For issues where the file is no longer in diff:
- Remove from `final_state` (done in Phase 4.2)
- Optionally delete the comment:
```bash
gh api repos/{owner}/{repo}/pulls/comments/{id} -X DELETE
```

---

## Phase 6: Summary Comment (STRICT: ONE SUMMARY ONLY)

**CRITICAL RULE: There must be exactly ONE summary comment per PR. The summary contains the INLINE_STATE that tracks all posted comments.**

### Step 6.1: Use Summary ID from Phase 2

You already fetched the existing summary in Phase 2.1. Use that `id` if it exists.

- If `existing_summary_id` exists → UPDATE (PATCH)
- If no existing summary → CREATE (POST)

### Step 6.2: Build Summary Content with INLINE_STATE

**The summary MUST include the hidden INLINE_STATE block:**

```markdown
## claude-code-review-summary

<!-- INLINE_STATE_START
[{"path":"src/auth.ts","issueHash":"a1b2c3d4","line":42,"commentId":123456},{"path":"src/db.ts","issueHash":"e5f6g7h8","line":87,"commentId":789012}]
INLINE_STATE_END -->

### Overview
<Brief description of changes reviewed>

### Inline Comments
**{N} issue(s) posted as inline comments** ({critical} critical, {suggestions} suggestions).

| Severity | File | Line | Issue |
| -------- | ---- | ---- | ----- |
| CRITICAL | `src/auth.ts` | 42 | Missing null check |
| SUGGESTION | `src/db.ts` | 87 | Consider parameterized query |

### Nits (Minor Issues)

| File | Line | Issue |
| ---- | ---- | ----- |
| `src/utils.ts` | 15 | Consider using const |

*These are minor style/preference items - address if you have time.*

### What's Good
<Positive aspects - be specific>

### Review Stats
- New comments posted: {n}
- Duplicates skipped: {n}
- Total tracked issues: {n}

---
*Generated with [Claude Code](https://claude.com/claude-code)*
```

### Step 6.3: Post or Update Summary

**IF existing summary found:**
```bash
gh api repos/{owner}/{repo}/issues/comments/{existing_summary_id} \
  -X PATCH \
  -f body="<summary content with INLINE_STATE>"
```

**ONLY IF no existing summary:**
```bash
gh api repos/{owner}/{repo}/issues/{pr_number}/comments \
  -X POST \
  -f body="<summary content with INLINE_STATE>"
```

### Step 6.4: Verify (MANDATORY)

After posting/updating, verify the INLINE_STATE is correctly saved:
```bash
gh api repos/{owner}/{repo}/issues/comments/{summary_id} --jq '.body' | grep -o 'INLINE_STATE_START.*INLINE_STATE_END'
```

---

## Constraints

- CI-only: Designed for CI environment
- Critical and Suggestions as inline comments
- Nits go to summary table ONLY (no inline comments for nits)
- **State-based deduplication is MANDATORY** - compare by path + issueHash, NOT line numbers
- Do NOT auto-resolve threads
- **ONE SUMMARY COMMENT PER PR** - This is a STRICT rule. ALWAYS update existing summary, NEVER create duplicates
- **Summary title MUST be `## claude-code-review-summary`** - this is used for detection
- **INLINE_STATE block is MANDATORY** - this tracks all posted inline comments across CI runs
