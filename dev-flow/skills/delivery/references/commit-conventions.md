# Commit Conventions

Follow these conventions for consistent, informative commit messages.

## Conventional Commits Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type (Required)

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat: add user profile endpoint` |
| `fix` | Bug fix | `fix: handle null user in auth` |
| `docs` | Documentation | `docs: update API reference` |
| `style` | Formatting | `style: fix indentation` |
| `refactor` | Code restructure | `refactor: extract validation logic` |
| `perf` | Performance | `perf: optimize database query` |
| `test` | Tests | `test: add user service tests` |
| `build` | Build system | `build: update webpack config` |
| `ci` | CI/CD | `ci: add deployment workflow` |
| `chore` | Maintenance | `chore: update dependencies` |
| `revert` | Revert commit | `revert: revert "feat: add X"` |

### Scope (Optional)

Indicates the area of change:

```
feat(auth): add OAuth2 support
fix(api): handle timeout errors
docs(readme): add installation guide
```

Common scopes:
- `api` - API endpoints
- `auth` - Authentication
- `db` - Database
- `ui` - User interface
- `config` - Configuration
- `deps` - Dependencies

### Subject (Required)

- Use imperative mood ("add" not "added")
- Don't capitalize first letter
- No period at end
- Max 50 characters

**Good**:
```
feat: add user authentication
fix: prevent null pointer in handler
```

**Bad**:
```
feat: Added user authentication.
fix: Fixed the bug
```

### Body (Optional)

- Explain what and why, not how
- Wrap at 72 characters
- Separate from subject with blank line

```
feat: add rate limiting to API

Implement token bucket algorithm to prevent abuse.
Limits are configurable per endpoint.

Default: 100 requests per minute per IP.
```

### Footer (Optional)

- Reference issues: `Fixes #123`, `Closes #456`
- Breaking changes: `BREAKING CHANGE: description`
- Co-authors: `Co-Authored-By: Name <email>`

```
feat: change authentication flow

BREAKING CHANGE: JWT tokens now expire after 1 hour instead of 24 hours.

Fixes #789
Co-Authored-By: Claude <noreply@anthropic.com>
```

## Feature Development Commits

For dev-flow features, use this template:

```
feat: [feature name]

[1-2 sentence description of what the feature does]

- [Key implementation detail 1]
- [Key implementation detail 2]
- [Key implementation detail 3]

Spec: [path to spec file]

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Example

```
feat: add user profile pictures

Allow users to upload and manage profile pictures with automatic
resizing and format conversion.

- Add /api/v1/users/:id/avatar endpoint
- Implement image processing with sharp
- Store images in S3 with CDN caching
- Add size limits (5MB) and format validation

Spec: spec/user-profile-pictures.md

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## PR Description Template

```markdown
## Summary

[Brief description - what does this PR do?]

## Changes

- [Change 1 with file reference]
- [Change 2 with file reference]
- [Change 3 with file reference]

## Test Plan

- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] [Specific test scenario 1]
- [ ] [Specific test scenario 2]

## Screenshots (if applicable)

[Add screenshots for UI changes]

## Checklist

- [ ] Code follows project conventions
- [ ] Tests pass locally
- [ ] Documentation updated
- [ ] No security vulnerabilities introduced
- [ ] PR title follows conventional commits

## Related

- Spec: `[path to spec]`
- Fixes #[issue number]

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

## Breaking Changes

When introducing breaking changes:

1. **In commit message**:
```
feat: update authentication API

BREAKING CHANGE: The /api/auth endpoint now requires
API version header. Clients without the header will
receive 400 Bad Request.

Migration: Add 'X-API-Version: 2' header to all auth requests.
```

2. **In PR description**:
```markdown
## ⚠️ Breaking Changes

This PR introduces breaking changes:

### Authentication API
- **Before**: No version header required
- **After**: `X-API-Version: 2` header required

### Migration Guide
1. Update all API clients to include version header
2. Deploy backend first
3. Update frontend within 24 hours
```

## Multi-Commit Features

For large features with multiple commits:

```
# Commit 1: Data layer
feat(db): add user avatar table

# Commit 2: Business layer
feat(service): implement avatar upload logic

# Commit 3: API layer
feat(api): add avatar upload endpoint

# Commit 4: Tests
test(avatar): add upload tests

# Squash message for PR merge:
feat: add user profile pictures (#123)
```

## Git Configuration

Ensure proper attribution:

```bash
# Set user info (if not global)
git config user.name "Your Name"
git config user.email "your@email.com"

# Enable commit signing (optional)
git config commit.gpgsign true
```

## Branch Naming

| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feat/[name]` | `feat/user-avatars` |
| Fix | `fix/[name]` | `fix/auth-timeout` |
| Docs | `docs/[name]` | `docs/api-reference` |
| Refactor | `refactor/[name]` | `refactor/auth-module` |

Use kebab-case for branch names.
