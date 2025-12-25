# Resolve PR Comments Workflow

## Arguments

```
$ARGUMENTS
```

## PR Number Resolution

**If PR number in arguments:**
```bash
gh pr view <PR_NUMBER> --json number,title --jq '"\(.number)|\(.title)"'
```

**If no PR number:**
```bash
git branch --show-current
gh pr view --json number,title --jq '"\(.number)|\(.title)"'
```

**If no PR found:**
```
Error: No PR found for current branch.

Usage:
  resolve-pr-comments        # Auto-detect from branch
  resolve-pr-comments 123    # PR #123
```

## Repository Info

```bash
gh repo view --json owner,name --jq '"\(.owner.login)/\(.name)"'
```

---

## Phase 1: Read Guideline

Parse guideline path from prompt. Default: `docs/codeReviewGuideline.md`

```bash
cat docs/codeReviewGuideline.md 2>/dev/null || echo "No guideline file found"
```

Use guideline to evaluate if reviewer feedback aligns with project standards.

---

## Phase 2: Fetch All PR Comments

### Step 2.1: Inline Review Comments

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  --jq '[.[] | {id, path, line, original_line, body, user: .user.login, in_reply_to_id, created_at, comment_type: "inline"}]'
```

### Step 2.2: Review Threads

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $pr: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $pr) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            comments(first: 10) {
              nodes {
                id
                databaseId
                body
                author { login }
                path
                line
              }
            }
          }
        }
      }
    }
  }
' -f owner="{owner}" -f repo="{repo}" -F pr={pr_number}
```

### Step 2.3: Filter to Unresolved

1. Build mapping: `comment_databaseId -> thread_id`
2. Skip comments where thread `isResolved: true`
3. Store `thread_id` for resolving later

### Step 2.4: General PR Comments

```bash
gh api repos/{owner}/{repo}/issues/{pr_number}/comments \
  --jq '[.[] | {id, body, user: .user.login, created_at, comment_type: "general"}]'
```

**Processing order:** Inline first, then general.

**If no unresolved comments:**
```
No unresolved review comments found on PR #{pr_number}!
```

---

## Phase 3: Interactive Resolution Loop

### Step 3.1: Analysis

1. **Relevance Check:** Is this actionable?
2. **Severity Assessment:** Blocker / Major / Minor / Questionable
3. **Guideline Alignment:** Does feedback match project standards?

### Step 3.2: Presentation

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Processing comment X of Y [Inline Review Comment]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**File:** path/to/file:42
**Reviewer:** @username
**Comment:** "The comment text"
**Assessment:** [Severity] - [Reasoning]
**Proposed Fix:** [Description]

[Show proposed code change]
```

### Step 3.3: User Decision

**Inline comments:**
- Fix - Apply change and reply
- Skip - Move to next
- Resolve - Mark resolved with reason

**General comments:**
- Fix - Apply changes and reply
- Skip - Move to next
- Acknowledge - Reply with explanation

### Handling Choices

**Fix (inline):**
1. Apply code change
2. Post reply: "Fixed in latest commit."
3. Resolve thread:
   ```bash
   gh api graphql -f query='
     mutation($threadId: ID!) {
       resolveReviewThread(input: {threadId: $threadId}) {
         thread { id isResolved }
       }
     }
   ' -f threadId="$thread_id"
   ```

**Resolve (inline):**
1. Post reply with reason
2. Resolve thread (same mutation)

**Fix/Acknowledge (general):**
1. Apply changes if needed
2. Post reply as new comment

### Progress Tracking

```
Progress: X of Y comments (F fixed, S skipped, R resolved, A acknowledged)
```

---

## Phase 4: Commit Changes

**If changes made:**
```bash
git add -A
git commit -m "fix: address PR review feedback"
```

---

## Phase 5: Final Options

- **Push** - Push commit to remote
- **Done** - Exit without pushing

---

## Constraints

- Process comments one by one
- Post replies before resolving threads
- Do NOT modify other users' comments
- Show clear progress indicators
