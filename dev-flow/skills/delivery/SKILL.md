---
name: delivery
description: This skill should be used when the user asks to "create a PR", "commit changes", "push to remote", "update documentation", "finish the feature", or mentions "delivery phase". Handles documentation updates, git commits, and PR creation.
---

# Delivery Phase

Complete the feature by updating documentation, creating commits, and opening a pull request. This phase packages all work for team review.

## Overview

The delivery phase:
- Updates project documentation
- Creates feature branch (if needed)
- Commits changes with conventional format
- Pushes and creates pull request

## Process

### Step 1: Update Documentation

Identify docs to update based on feature:

```markdown
## Documentation Updates

The following files may need updates:

- [ ] `CLAUDE.md` - Add feature to conventions/patterns
- [ ] `README.md` - Update feature list
- [ ] `CHANGELOG.md` - Add to unreleased section
- [ ] API docs - [already done via swagger if enabled]

Which documentation should I update?
```

Present proposed changes for approval before applying.

### Step 2: Optional - Postman Sync

If `enablePostman` is true in session config, invoke the postman skill to add endpoints to the collection.

### Step 3: Create Feature Branch

Check current branch:

```bash
git branch --show-current
```

If on main/master, create feature branch:

```bash
git checkout -b feat/[feature-name]
```

### Step 4: Stage and Commit

Stage all changes:

```bash
git add -A
git status
```

Check for PR template:

```bash
ls .github/PULL_REQUEST_TEMPLATE.md 2>/dev/null || \
ls .github/pull_request_template.md 2>/dev/null
```

Create commit with conventional format:

```bash
git commit -m "$(cat <<'EOF'
feat: [feature name]

[Description from spec]

- [Key change 1]
- [Key change 2]
- [Key change 3]

Spec: [spec file path]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### Step 5: Push and Create PR

Push to remote:

```bash
git push -u origin feat/[feature-name]
```

Create PR using GitHub CLI:

```bash
gh pr create --title "feat: [feature name]" --body "$(cat <<'EOF'
## Summary

[Brief description of the feature]

## Changes

- [Change 1]
- [Change 2]
- [Change 3]

## Test Plan

- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Spec

See `[spec file path]` for full specification.

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### Step 6: Archive Session

Move completed session to archive:

```bash
mkdir -p .dev-flow-sessions
mv .dev-flow-session.json ".dev-flow-sessions/[feature]-$(date +%Y%m%d-%H%M%S).json"
```

### Step 7: Present Summary

```markdown
## Feature Development Complete

**Feature**: [name]
**Spec**: [path]
**PR**: #[number] - [url]

### Phases Completed
✅ Discovery
✅ Planning
✅ Specification
✅ Implementation
✅ Review
✅ Delivery

### Files Changed
- Created: [count]
- Modified: [count]
- Tests: [count]

### Next Steps
- Review PR comments when CI completes
- Use `/dev-flow:resume` if fixes needed
```

## Session State

Update `.dev-flow-session.json` before archiving:

```json
{
  "status": "completed",
  "phases": {
    "6_delivery": {
      "status": "completed",
      "output": {
        "docsUpdated": ["CLAUDE.md", "README.md"],
        "postmanAdded": false,
        "branch": "feat/feature-name",
        "commits": ["abc123"],
        "prNumber": 42,
        "prUrl": "https://github.com/user/repo/pull/42",
        "completedAt": "ISO-8601 timestamp"
      }
    }
  }
}
```

## Commit Message Format

Follow conventional commits:

| Type       | Description                                         |
| ---------- | --------------------------------------------------- |
| `feat`     | New feature                                         |
| `fix`      | Bug fix                                             |
| `docs`     | Documentation only                                  |
| `refactor` | Code change that neither fixes bug nor adds feature |
| `test`     | Adding or updating tests                            |
| `chore`    | Maintenance tasks                                   |

## Standalone Usage

When invoked directly:
1. Ask for implementation context
2. Ask which docs to update
3. Follow the process above
4. Present completion summary

## Additional Resources

### Reference Files

For commit message conventions and PR templates:
- **`references/commit-conventions.md`** - Conventional commits guide and examples
