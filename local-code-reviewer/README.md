# Local Code Reviewer

Local code review skills for pre-PR review and PR comment resolution. Uses same classification criteria as `github-pr-reviewer` for consistency between CI and local workflows.

## Features

- **review-and-fix**: Review local changes before creating a PR
- **resolve-pr-comments**: Address reviewer feedback on existing PRs
- **Same Criteria**: Uses identical classification as CI for consistency
- **Custom Guidelines**: Reads your `docs/codeReviewGuideline.md`

## Installation

```bash
/plugin install local-code-reviewer@geekmini-claude-code-plugins
```

Or add the marketplace:

```bash
/plugin marketplace add geekmini/claude-code-marketplace
```

## Skills

### review-and-fix

Review local changes before creating a PR.

**Usage:**
```
> review my changes
> review my changes with guideline at .github/REVIEW.md
```

**Features:**
- Compares current branch to base (main/master)
- Interactive fix/skip/document loop
- Tech debt documentation option
- Commits fixes when done

### resolve-pr-comments

Address reviewer feedback on existing PRs.

**Usage:**
```
> resolve PR comments
> resolve PR comments 123
> resolve PR comments with guideline at .github/REVIEW.md
```

**Features:**
- Fetches unresolved review threads
- Interactive fix/skip/resolve loop
- Automatic thread resolution after fixes
- Commits and optionally pushes

## Guideline File

Both skills read guidelines from `docs/codeReviewGuideline.md` by default. Create this file with your review criteria:

```markdown
# Code Review Guidelines

## Critical Issues (Must Fix)
- Bugs that will cause failures
- Security vulnerabilities
- Architectural violations

## Suggestions (Nice to Have)
- Style inconsistencies
- Alternative approaches

## Focus Areas
- Error handling
- Performance
- Security
```

Pass a custom path in the prompt if your guideline is elsewhere.

## Consistency with CI

This plugin uses the same issue classification as `github-pr-reviewer`:

| Severity | Description | CI Behavior | Local Behavior |
|----------|-------------|-------------|----------------|
| Critical | Bugs, security, architecture | Inline comment | Must fix |
| Major | Performance, maintainability | Summary table | Strong suggestion |
| Minor | Style, alternatives | Summary table | Nit |

This ensures engineers see consistent feedback locally and in CI.

## Workflow Integration

**Recommended workflow:**

1. Make changes on feature branch
2. Run `review my changes` before PR
3. Fix critical issues locally
4. Create PR
5. CI runs `github-pr-reviewer` (same criteria)
6. If reviewer comments, run `resolve PR comments`

## Author

**GeekMini** - [https://github.com/geekmini](https://github.com/geekmini)

## License

MIT
