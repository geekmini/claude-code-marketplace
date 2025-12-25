# Local Code Review Workflow

## Arguments

```
$ARGUMENTS
```

## Branch Detection

**If base branch in arguments:** Use that.

**If no arguments:**
```bash
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
```
Fall back to `main` or `master`.

---

## Phase 1: Execute Review

1. Read `{GUIDELINE_PATH}` for review criteria
2. Reference `CLAUDE.md` for project standards (if exists)

Execute:
```bash
git diff --name-only <base>...HEAD
git diff <base>...HEAD
```

---

## Phase 2: Classify and Sort

**Critical** - Must fix:
- Bugs, security vulnerabilities
- Anti-patterns per guideline

**Major** - Strong suggestions:
- Performance issues
- Poor maintainability

**Minor** - Nits:
- Style, naming
- Alternatives

**Sort:** Critical → Major → Minor

---

## Phase 3: Interactive Fix Loop

For each issue:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Processing issue X of Y
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**File:** path/to/file:42
**Severity:** Critical | Major | Minor
**Issue:** Description
**Proposed Fix:** How to fix

[Show proposed code change]
```

**Options:**
- **Fix** - Apply the change
- **Skip** - Move to next
- **Document** - Record as tech debt

**Document** appends to `docs/technical_debt.md`:
```markdown
## [YYYY-MM-DD] Branch: <branch>

### <Brief title>
- **File:** <path>:<line>
- **Severity:** <level>
- **Issue:** <description>
- **Why deferred:** Acknowledged during review
```

### Progress Tracking

```
Progress: X of Y issues (F fixed, S skipped, D documented)
```

---

## Phase 4: Commit Changes

**If changes made:**
```bash
git add -A
git commit -m "fix: address code review feedback

Resolved:
- [List fixes]
"
```

---

## Phase 5: Final Options

- **Re-review** - Run full review again
- **Done** - Exit

---

## Constraints

- Do NOT post GitHub comments (local-only)
- Do NOT interact with GitHub API
- Show clear progress indicators
