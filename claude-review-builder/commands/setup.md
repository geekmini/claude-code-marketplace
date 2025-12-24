---
description: Set up Claude Code review infrastructure in the current repository. Creates commands, prompts, workflow, and a template guideline.
---

# Claude Code Review Setup

This command sets up intelligent code review infrastructure for your repository.

## Step 0: Check Existing Setup

First, check if Claude Code review infrastructure already exists:

```bash
ls -la .claude/commands/review-pr-ci.md .github/workflows/code-review.yml 2>/dev/null
```

**Build a status report:**

| File | Status |
|------|--------|
| `.claude/commands/review-pr-ci.md` | ✅ Exists / ❌ Missing |
| `.claude/commands/resolve-pr-comments.md` | ✅ Exists / ❌ Missing |
| `.claude/commands/review-and-fix.md` | ✅ Exists / ❌ Missing |
| `.claude/prompts/review-pr.md` | ✅ Exists / ❌ Missing |
| `.github/workflows/code-review.yml` | ✅ Exists / ❌ Missing |

**If ALL core files exist** (review-pr-ci.md AND code-review.yml):

Show status and ask user:

```
Claude Code review is already set up in this repository.

Existing files:
- .claude/commands/review-pr-ci.md ✅
- .claude/commands/resolve-pr-comments.md ✅
- .claude/commands/review-and-fix.md ✅
- .claude/prompts/review-pr.md ✅
- .github/workflows/code-review.yml ✅

What would you like to do?
```

**Options:**
- **Exit** - Keep existing setup, no changes
- **Update** - Overwrite all files with latest templates
- **Show diff** - Compare existing files with templates

**If user selects Exit:** Stop here with message "No changes made."

**If user selects Show diff:** Read each existing file and show differences from templates, then ask again.

**If user selects Update:** Continue to Step 1 (will overwrite files).

**If SOME files are missing:**

Show what exists vs missing:

```
Partial Claude Code review setup detected.

Existing:
- .claude/commands/review-pr-ci.md ✅

Missing:
- .claude/commands/resolve-pr-comments.md ❌
- .github/workflows/code-review.yml ❌

Proceeding will create missing files and update existing ones.
```

Then continue to Step 1.

**If NO files exist:** Continue to Step 1 (fresh setup).

---

## Step 1: Gather Information

First, ask the user for the code review guideline path using `AskUserQuestion`:

```
Where should the code review guideline file be located?
```

**Options:**
- `docs/code-review-guideline.md` (Recommended) - Standard location
- Custom path - Let me specify a different path

**If user selects custom path**, ask them to provide the path.

Store the path as `GUIDELINE_PATH` (default: `docs/code-review-guideline.md`).

## Step 2: Create Branch

Create a new branch for the setup:

```bash
git checkout -b setup/claude-code-review
```

## Step 3: Create Directory Structure

Create the necessary directories:

```bash
mkdir -p .claude/commands .claude/prompts .github/workflows
```

Also create the directory for the guideline file:

```bash
mkdir -p $(dirname {GUIDELINE_PATH})
```

## Step 4: Create Files

Create all the following files. Replace `{GUIDELINE_PATH}` with the actual path from Step 1.

### 4.1: Create `.claude/commands/review-pr-ci.md`

```markdown
---
description: Review a pull request in CI mode. Posts/updates GitHub inline comments and summary comment.
---

## CI Environment Check

**IMPORTANT**: This command is designed for CI automation only.

First, check if running in a CI environment:
\`\`\`bash
echo "CI=$CI, GITHUB_ACTIONS=$GITHUB_ACTIONS"
\`\`\`

**If NOT in CI** (both `CI` and `GITHUB_ACTIONS` are empty or unset):

> **Note:** These are checked as OR conditions - having either `CI=true` OR `GITHUB_ACTIONS=true` is sufficient.

Show error and exit immediately:
\`\`\`
Error: /review-pr-ci is for CI automation only.

This command posts comments to GitHub as the bot. For local use, choose:

  /resolve-pr-comments    # Respond to human reviewer comments interactively
  /review-and-fix         # Local code review with fix loop (no PR required)

To trigger automated CI review, push your branch and open/sync a PR.
\`\`\`

**Do not proceed further.** Stop execution here.

**If in CI** (either `CI=true` or `GITHUB_ACTIONS=true`):

Proceed with the review.

---

## Arguments

\`\`\`
$ARGUMENTS
\`\`\`

## PR Number Resolution

Parse arguments for a PR number. If not provided, auto-detect from current branch:

1. Get current branch:
   \`\`\`bash
   git branch --show-current
   \`\`\`

2. Find PR for current branch:
   \`\`\`bash
   gh pr view --json number --jq '.number'
   \`\`\`

3. If no PR found, show error:
   \`\`\`
   Error: No PR found for current branch.

   Usage:
     /review-pr-ci        # Auto-detect PR from branch
     /review-pr-ci 123    # Review PR #123
   \`\`\`

## Repository Info

Get owner and repo from the current repository:
\`\`\`bash
gh repo view --json owner,name --jq '"\(.owner.login)/\(.name)"'
\`\`\`

---

## Error Handling

All GitHub API calls should implement basic error handling:

1. **Rate Limiting:** If rate limited (HTTP 403 with `X-RateLimit-Remaining: 0`):
   - Log the error with reset time
   - Exit gracefully: "GitHub API rate limit reached. Review will retry on next push."

2. **Permission Errors:** If bot lacks permissions (HTTP 403/401):
   - Log the specific permission needed
   - Post a summary comment (if possible) indicating permission issue
   - Exit with error code

3. **Network Failures:** Retry once with 5-second delay, then fail

4. **PR State Changes:** If PR is closed/merged during execution:
   - Exit gracefully: "PR was closed or merged during review"

5. **GraphQL Errors:** Check response for `errors` field:
   - Log the GraphQL error message
   - Fall back to REST API if available, otherwise skip that operation

**Critical vs Non-Critical Operations:**
- **Critical** (block execution): Fetching PR diff, posting summary comment
- **Non-Critical** (log and continue): Individual inline comments, orphan cleanup

---

## Phase 1: Code Review Analysis

### Step 1.1: Read Review Guidelines

Read and apply the review criteria:
1. Read `{GUIDELINE_PATH}` for detailed review criteria
2. Read `.claude/prompts/review-pr.md` for the core review process
3. Reference `CLAUDE.md` for project standards (if exists)

### Step 1.2: Execute Review

1. Use `gh pr view` to understand PR context and description
2. Use `gh pr diff` to see the actual changes
3. Read relevant source files for deeper context using `Read`, `Grep`, `Glob`
4. Evaluate against focus areas defined in your guideline

### Step 1.3: Classify Issues

For each issue found, classify as:

**CRITICAL** (will be posted as inline comments):
- Bugs that will cause failures
- Security vulnerabilities
- Code that definitively worsens code health
- Violations of architectural principles
- Anti-patterns specific to your tech stack (defined in guideline)

**SUGGESTIONS** (will go to summary table only, NOT inline comments):
- Minor style inconsistencies
- Alternative approaches worth considering
- Educational comments about best practices
- Optional refactoring ideas

Store findings in two lists:
- `critical_issues`: Array of `{path, line, body}`
- `suggestions`: Array of `{path, line, description}`

---

## Phase 2: State Discovery

### Step 2.1: Fetch Existing Bot Comments

Fetch all existing inline comments from the bot (include body for similarity check):

\`\`\`bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  --jq '[.[] | select(.user.login == "github-actions[bot]" or .user.login == "claude[bot]") | {id, path, line, original_line, body}]'
\`\`\`

### Step 2.2: Fetch Review Thread Resolution Status

Query GraphQL to get which threads are resolved:

\`\`\`bash
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
\`\`\`

**Pagination check:** If `pageInfo.hasNextPage` is true, add a warning in the summary.

Build a mapping: `comment_databaseId → {thread_id, isResolved}`

### Step 2.3: Filter to Unresolved Comments

From the existing bot comments (Step 2.1), filter to only those where:
- The corresponding thread has `isResolved: false`
- OR no matching thread found (treat as unresolved)

Store as `unresolved_comments`: Array of `{id, path, line, body, thread_id}`

### Step 2.4: Get Current PR Diff Files

Get the list of files currently in the PR diff:

\`\`\`bash
gh pr diff {pr_number} --name-only
\`\`\`

Store as `diff_files`: Array of file paths currently in the PR.

---

## Phase 3: Semantic Deduplication (MANDATORY)

**CRITICAL:** This phase MUST be executed rigorously. Skipping or rushing this phase will result in duplicate comments.

For each CRITICAL issue you want to post, check if a similar unresolved comment already exists.

### Step 3.1: Find Existing Comments at Same Location

For each critical issue at `{path, line}`:

1. Find ALL unresolved comments where:
   - Same `path` AND
   - `line` or `original_line` is within **±5 lines** of the issue location
   - **Note:** GitHub sets `line: null` when the commented code is no longer in the diff. Use `original_line` for proximity checks.

2. If no matching comments at this location → Mark as `POST_NEW`

3. If one or more existing comments found → Proceed to Step 3.2

### Step 3.2: LLM Semantic Similarity Check

For each existing unresolved comment at the same location, perform semantic analysis:

**Compare the existing comment body with your new issue. Ask yourself:**
- Are they addressing the SAME underlying code problem?
- Would fixing one issue also fix the other?
- Is this the same anti-pattern or bug, even if worded differently?

**Decision:**
- If ANY matching comment is **SIMILAR** → `SKIP` - Do not post
- If ANY matching comment is **EVOLVED** → `UPDATE` - Update existing comment
- If ALL matching comments are **DIFFERENT** → `POST_NEW`

### Step 3.3: Output Deduplication Decision Table (MANDATORY)

**BEFORE proceeding to Phase 4, you MUST output a decision table:**

\`\`\`
Deduplication Analysis:
| New Issue | Line | Existing Comment | Line | Semantic Match | Decision |
|-----------|------|------------------|------|----------------|----------|
| Issue A   | 26   | "Similar..."     | 24   | SIMILAR        | SKIP     |
| Issue B   | 43   | (none nearby)    | -    | -              | POST_NEW |
\`\`\`

This table is MANDATORY.

Store decisions for each critical issue: `{path, line, action: POST_NEW | SKIP | UPDATE, existing_comment_id?}`

---

## Phase 4: Comment Reconciliation

**PREREQUISITE:** Phase 3's Deduplication Decision Table MUST be completed before this phase.

### Step 4.1: Post New Critical Issues

For each critical issue marked `POST_NEW` in the decision table:

Create a new inline comment:
\`\`\`
mcp__github_inline_comment__create_inline_comment
\`\`\`

### Step 4.2: Update Evolved Issues

For each critical issue marked `UPDATE`:

\`\`\`bash
gh api repos/{owner}/{repo}/pulls/comments/{existing_comment_id} -X PATCH -f body="<updated comment body>"
\`\`\`

### Step 4.3: Skip Duplicates

For each critical issue marked `SKIP`:
- Log: "Skipped duplicate: {path}:{line} - similar issue already flagged"
- Do NOT post any comment

---

## Phase 5: State Synchronization

### Step 5.1: Notify Fixed Issues (User Resolves)

When an issue appears to be fixed, post an informative reply but **do NOT auto-resolve** the thread.

**IMPORTANT:** Group comments by unique issue first to avoid duplicate replies.

For each **unique issue group**:

1. **Check if issue still exists in current review findings**

2. **If issue appears FIXED**:
   - Post ONE reply to the FIRST comment:
     \`\`\`bash
     gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
       -X POST \
       -f body="✅ This issue appears to be addressed. Please verify and resolve this thread." \
       -F in_reply_to={first_comment_id}
     \`\`\`
   - **Do NOT auto-resolve** - let the user verify and resolve manually

3. **If issue PERSISTS:** Leave comments as-is

### Step 5.2: Delete Orphaned Comments

For each unresolved bot comment:

1. **Check if file still in PR diff**

2. **If file NOT in diff**:
   \`\`\`bash
   gh api repos/{owner}/{repo}/pulls/comments/{comment_id} -X DELETE
   \`\`\`
   Log: "Deleted orphaned comment: {path}:{line} - file no longer in PR"

3. **If file still in diff:** Keep the comment

---

## Phase 6: Summary Comment

### Step 6.1: Find Existing Summary Comment

\`\`\`bash
gh api repos/{owner}/{repo}/issues/{pr_number}/comments \
  --jq '[.[] | select((.user.login == "github-actions[bot]" or .user.login == "claude[bot]") and (.body | contains("## Code Review Summary"))) | .id] | first'
\`\`\`

### Step 6.2: Update or Create Summary

**If comment ID found:** Update existing comment
**If no comment found:** Create new comment

### Summary Comment Format

\`\`\`markdown
## Code Review Summary

### Overview
<Brief description of what the PR does>

### Critical Issues
<If critical issues were posted as inline comments:>
**{N} critical issue(s) posted as inline comments.** Please review and address each one.

<If no critical issues:>
**None found.** The changes look good.

### Suggestions

| File | Line | Issue |
|------|------|-------|
| \`path/to/file\` | 42 | Description |

### What's Good
<Acknowledge positive aspects>

### Review Actions
- Critical issues posted: {count}
- Duplicates skipped: {count}
- Fixed issues notified: {count}
- Orphaned comments deleted: {count}

### Files Reviewed

| File | Status |
|------|--------|
| \`path/to/file\` | Summary |

---
**Review Cost**
- Total cost: $X.XX

Generated with [Claude Code](https://claude.com/claude-code)
\`\`\`

---

## Constraints

- **CI-only**: This command MUST only run in CI environments
- **Critical issues only as inline**: Suggestions go to summary table
- **Semantic deduplication is MANDATORY**
- **Fixed issue notification**: Post reply, do NOT auto-resolve
- **Smart orphan cleanup**: Only delete when file removed from PR
- Only ONE summary comment per PR
- **Pagination limits**: GraphQL queries fetch up to 100 review threads

---

## Edge Cases

### Clean PR (No Issues)
- Still post a summary comment
- Critical Issues: "**None found.** The changes look good."

### Zero Diff Files
- Delete ALL existing bot inline comments
- Post summary noting: "PR has no file changes to review."

### Bot Identity
Check for both `github-actions[bot]` and `claude[bot]`.
```

### 4.2: Create `.claude/commands/resolve-pr-comments.md`

```markdown
---
description: Resolve GitHub PR review comments interactively. Fetches comments, helps fix them, posts replies, and resolves threads.
---

## Arguments

\`\`\`
$ARGUMENTS
\`\`\`

## PR Number Resolution

Parse arguments for a PR number. If not provided, auto-detect from current branch:

**If PR number provided in arguments:**
\`\`\`bash
gh pr view <PR_NUMBER> --json number,title --jq '"\(.number)|\(.title)"'
\`\`\`

**If no PR number provided:**
1. Get current branch:
   \`\`\`bash
   git branch --show-current
   \`\`\`

2. Find PR for current branch:
   \`\`\`bash
   gh pr view --json number,title --jq '"\(.number)|\(.title)"'
   \`\`\`

**If no PR found, show error:**
\`\`\`
Error: No PR found for current branch.

Usage:
  /resolve-pr-comments        # Auto-detect PR from branch
  /resolve-pr-comments 123    # Resolve comments on PR #123
\`\`\`

## Repository Info

\`\`\`bash
gh repo view --json owner,name --jq '"\(.owner.login)/\(.name)"'
\`\`\`

## Phase 1: Fetch All PR Comments

### Step 1: Fetch Inline Review Comments

\`\`\`bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  --jq '[.[] | {id, path, line, original_line, body, user: .user.login, in_reply_to_id, created_at, comment_type: "inline"}]'
\`\`\`

### Step 2: Fetch Review Threads

\`\`\`bash
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
\`\`\`

### Step 2.5: Build Thread Mapping and Filter to Unresolved

1. Build mapping from `comment_databaseId → thread_id`
2. Skip comments whose thread has `isResolved: true`
3. Store `thread_id` for use when resolving

### Step 3: Fetch General PR Comments

\`\`\`bash
gh api repos/{owner}/{repo}/issues/{pr_number}/comments \
  --jq '[.[] | {id, body, user: .user.login, created_at, comment_type: "general"}]'
\`\`\`

### Processing Order

1. **First**: Process unresolved inline review comments
2. **Last**: Process general PR comments

**If no unresolved comments:**
\`\`\`
No unresolved review comments found on PR #{pr_number}!
\`\`\`

## Phase 2: Interactive Resolution Loop

For each comment:

### Step 1: Analysis

1. **Relevance Check:** Is this comment actionable?
2. **Severity Assessment:** Blocker / Major / Minor / Questionable

### Step 2: Presentation

**For inline comments:**
\`\`\`
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Processing comment X of Y [Inline Review Comment]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**File:** path/to/file:42
**Reviewer:** @username
**Comment:** "The comment text"
**Assessment:** [Severity] - [Reasoning]
**Proposed Fix:** [Description]

[Show proposed code change]
\`\`\`

### Step 3: User Decision

**For inline comments - Options:**
- **Fix** - Apply code change and reply
- **Skip** - Move to next without changes
- **Resolve** - Mark resolved without code changes

**For general comments - Options:**
- **Fix** - Apply code changes and reply
- **Skip** - Move to next without changes
- **Acknowledge** - Reply with explanation

### Handling Choices

**Fix (inline):**
1. Apply code change
2. Post reply: "Fixed in latest commit. [Automated reply]"
3. Resolve thread via GraphQL:
   \`\`\`bash
   gh api graphql -f query='
     mutation($threadId: ID!) {
       resolveReviewThread(input: {threadId: $threadId}) {
         thread { id isResolved }
       }
     }
   ' -f threadId="$thread_id"
   \`\`\`

**Resolve (inline):**
1. Post reply with reason
2. Resolve thread via GraphQL (same mutation as above)

**Fix/Acknowledge (general):**
1. Apply changes if needed
2. Post reply as new comment

### Progress Tracking

\`\`\`
Progress: X of Y comments processed (F fixed, S skipped, R resolved, A acknowledged)
\`\`\`

## Phase 3: Commit Changes

**If code changes made:**
\`\`\`bash
git add -A
git commit -m "fix: address PR review feedback"
\`\`\`

## Phase 4: Final Options

**Options:**
- **Push** - Push commit to remote
- **Done** - Exit without pushing

## Constraints

- Process comments one by one
- Always post replies before resolving threads
- Do NOT modify other users' comments
- Show clear progress indicators
```

### 4.3: Create `.claude/commands/review-and-fix.md`

```markdown
---
description: Run a local code review and interactively fix issues one by one. Works without a PR.
---

## Arguments

\`\`\`
$ARGUMENTS
\`\`\`

## Branch Detection

**If base branch provided in arguments:**
- Use that as the base branch

**If no arguments:**
1. Get current branch
2. Detect default base branch:
   \`\`\`bash
   git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
   \`\`\`
   Fall back to `main` or `master` if that fails.

## Phase 1: Execute Review

1. Read `{GUIDELINE_PATH}` for review criteria
2. Read `.claude/prompts/review-pr.md` for core process
3. Reference `CLAUDE.md` for project standards (if exists)

Execute:
\`\`\`bash
git diff --name-only <base_branch>...HEAD
git diff <base_branch>...HEAD
\`\`\`

## Phase 2: Classify and Sort Issues

**Critical** - Must fix:
- Bugs, security vulnerabilities
- Anti-patterns per your guideline

**Major** - Strong suggestions:
- Performance issues, poor maintainability

**Minor** - Nits:
- Style, naming, alternatives

**Sort by severity: Critical → Major → Minor**

## Phase 3: Interactive Fix Loop

For each issue:

\`\`\`
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Processing issue X of Y
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**File:** path/to/file:42
**Severity:** Critical | Major | Minor
**Issue:** Description
**Proposed Fix:** How to fix

[Show proposed code change]
\`\`\`

**Options:**
- **Fix** - Apply the change
- **Skip** - Move to next
- **Document** - Record as tech debt

**Document** appends to `docs/technical_debt.md`:
\`\`\`markdown
## [YYYY-MM-DD] Branch: <branch_name>

### <Brief title>
- **File:** <path>:<line>
- **Severity:** <level>
- **Issue:** <description>
- **Why deferred:** Acknowledged during review
\`\`\`

### Progress Tracking

\`\`\`
Progress: X of Y issues (F fixed, S skipped, D documented)
\`\`\`

## Phase 4: Commit Changes

**If code changes made:**
\`\`\`bash
git add -A
git commit -m "fix: address code review feedback

Resolved:
- [List fixes]
"
\`\`\`

## Phase 5: Final Options

**Options:**
- **Re-review** - Run full review again
- **Done** - Exit

## Constraints

- Do NOT post GitHub comments (local-only mode)
- Do NOT interact with GitHub API
- Show clear progress indicators
```

### 4.4: Create `.claude/prompts/review-pr.md`

```markdown
# Code Review Core Prompt

Review this pull request and provide constructive feedback.

## Guidelines

Read and apply the comprehensive review criteria from `{GUIDELINE_PATH}`.

Also reference project standards from `CLAUDE.md` (if exists).

## Review Process

1. **Understand the Change**
   - Read the PR description using `gh pr view`
   - Review the changed files using `gh pr diff`
   - Consider the broader context of the codebase

2. **Apply Review Guidelines**
   - Follow all focus areas in your guideline
   - Check for bugs, edge cases, and error handling

3. **Classify Issues**
   - **Critical**: Must fix before merge (bugs, security, anti-patterns)
   - **Suggestions**: Prefix with "Nit:" (style, alternatives, best practices)

## Commands Available

- `gh pr diff` - See the actual changes
- `gh pr view` - See PR description and context
- `Read`, `Grep`, `Glob` - Explore codebase for context

## Remember

Your goal is to provide helpful feedback for continuous improvement. Human reviewers make the final approval decision.
```

### 4.5: Create `.github/workflows/code-review.yml`

```yaml
name: Claude Code Review

# AI-powered code review on pull requests using Claude Code.
#
# Triggers: PR opened, synchronized (new commits pushed), or ready_for_review
#
# Requirements:
# - ANTHROPIC_API_KEY secret must be configured

on:
  pull_request:
    types: [opened, synchronize, ready_for_review]

concurrency:
  group: claude-review-${{ github.event.pull_request.number }}
  cancel-in-progress: true

jobs:
  claude-review:
    runs-on: ubuntu-latest
    if: github.event.pull_request.draft == false
    permissions:
      contents: read
      pull-requests: write
      issues: read
      id-token: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Run Claude Code Review
        id: claude-code-review
        uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          prompt: |
            Review PR #${{ github.event.pull_request.number }} in ${{ github.repository }}.

            Execute /review-pr-ci ${{ github.event.pull_request.number }}

          claude_args: |
            --model claude-opus-4-5 --allowed-tools "Bash(gh api:*),Bash(gh issue view:*),Bash(gh search:*),Bash(gh issue list:*),Bash(gh pr comment:*),Bash(gh pr diff:*),Bash(gh pr view:*),Bash(gh pr list:*),Bash(gh repo view:*),mcp__github_inline_comment__create_inline_comment,Read,Grep,Glob"
```

### 4.6: Create Template Guideline at `{GUIDELINE_PATH}`

```markdown
# Code Review Guidelines

## Core Principles

- Focus on actionable feedback that improves code health
- Balance critical feedback with non-blocking suggestions (use "Nit:" prefix)
- Technical facts and data override personal opinions
- Be direct and concise
- If code is fine, don't comment on it; silence means approval

## Review Process

1. **Understand the Change**
   - Read the PR description
   - Understand what problem this code solves
   - Consider the broader context

2. **Evaluate Code Health**
   - Does this make the system easier or harder to maintain?
   - Is the code more readable than before?
   - Does it follow established patterns?
   - Are there obvious bugs or edge cases not handled?

## Focus Areas

### Design & Architecture
- Does the code fit with the overall system design?
- Are there better architectural approaches?
- Is separation of concerns followed?

### Functionality
- Does the code do what the author intended?
- Are there edge cases not handled?
- Is error handling appropriate?

### Complexity
- Can other developers understand this code quickly?
- Is the code over-engineered?
- Should any code be broken into smaller functions?

### Tests
- Are there appropriate tests for new functionality?
- Do tests cover error cases and edge cases?

### Naming & Style
- Are variables, functions, and classes named clearly?
- Does code follow existing patterns in the codebase?

## Critical vs Suggestions

**Critical (must fix):**
- Bugs that will cause failures
- Security vulnerabilities
- Code that worsens code health
- Violations of architectural principles

**Suggestions (prefix with "Nit:"):**
- Minor style inconsistencies
- Alternative approaches
- Educational comments
- Optional refactoring ideas
```

## Step 5: Stage and Commit

```bash
git add -A
git commit -m "feat: add Claude Code review infrastructure

- Add /review-pr-ci command for CI automated review
- Add /resolve-pr-comments for interactive comment resolution
- Add /review-and-fix for local review without PR
- Add GitHub Actions workflow for PR reviews
- Add template code review guideline

Features:
- Semantic deduplication prevents duplicate comments
- Smart orphan cleanup when files removed
- Single summary comment per PR (updates, not duplicates)
- Fixed issue notification (user verifies and resolves)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## Step 6: Push and Create PR

```bash
git push -u origin setup/claude-code-review
```

Create the PR:

```bash
gh pr create --title "feat: add Claude Code review infrastructure" --body "$(cat <<'EOF'
## Summary

Set up intelligent Claude Code review infrastructure with:

- `/review-pr-ci` - CI automated review with semantic deduplication
- `/resolve-pr-comments` - Interactive comment resolution
- `/review-and-fix` - Local review without PR
- GitHub Actions workflow for automatic PR reviews
- Template code review guideline

## Features

- **Semantic Deduplication** - Prevents duplicate comments across PR updates
- **Smart Comment Management** - Critical issues as inline, suggestions in summary
- **Fixed Issue Notification** - Posts reply when fixed, user verifies and resolves
- **Orphan Cleanup** - Deletes comments when files removed from PR
- **Single Summary** - Updates existing summary, never duplicates

## Setup Required

1. Add `ANTHROPIC_API_KEY` secret to repository settings
2. Customize `{GUIDELINE_PATH}` for your project's standards

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

## Step 7: Confirm Success

Show the user:

```
✅ Claude Code review infrastructure has been set up!

Created files:
- .claude/commands/review-pr-ci.md
- .claude/commands/resolve-pr-comments.md
- .claude/commands/review-and-fix.md
- .claude/prompts/review-pr.md
- .github/workflows/code-review.yml
- {GUIDELINE_PATH}

PR created: [show PR URL]

Next steps:
1. Add ANTHROPIC_API_KEY secret to your repository
2. Customize {GUIDELINE_PATH} for your project
3. Merge the PR to enable automated reviews
```
