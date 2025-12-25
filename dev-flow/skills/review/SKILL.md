---
name: review
description: This skill should be used when the user asks to "review the code", "check for issues", "code review", "find bugs", or mentions "review phase". Provides interactive code review with confidence-based issue filtering.
---

# Review Phase

Conduct interactive code review using the code-reviewer agent. Issues are filtered by confidence score to focus on high-priority problems.

## Overview

The review phase:
- Launches code-reviewer agent on implementation
- Filters issues by confidence (>=80% reported)
- Provides interactive fix loop
- Updates spec status on completion

## Process

### Step 1: Launch Code Reviewer

Use the Task tool:

```
Task tool:
  subagent_type: "code-reviewer"
  prompt: |
    Review the implementation for: [feature name]

    Files to review:
    [list from implementation phase]

    Spec file: [path]
    Conventions: [from discovery]

    Check for:
    - Bugs and logic errors
    - Security vulnerabilities
    - Code quality issues
    - Convention adherence

    Only report issues with confidence >= 80%.
```

### Step 2: Present Review Results

```markdown
## Code Review Results

**Files Reviewed**: [count]
**Issues Found**: [count with confidence >= 80]

### Critical Issues

#### Issue 1
- **Confidence**: [score]%
- **File**: `path/to/file.ext:line`
- **Category**: [Bug | Security | Convention | Quality]
- **Issue**: [description]
- **Suggested Fix**: [specific fix]

---

### High Priority Issues

[Same format]

---

### Summary

**Overall Assessment**: [Needs Changes | Minor Issues | Approved]
```

### Step 3: Interactive Fix Loop

For each issue found:

```markdown
**Issue [N] of [Total]**

File: `path/to/file.ext:123`
Category: [category]
Confidence: [score]%

**Issue**: [description]

**Suggested Fix**: [fix details]

Options:
1. Fix this issue
2. Skip (with reason)
3. Need more context
```

Apply fixes as approved.

### Step 4: Re-Review (if fixes applied)

After applying fixes, re-run the code reviewer:

```markdown
## Re-Review Results

**Previous Issues**: [count]
**Fixed**: [count]
**Remaining**: [count]
**New Issues**: [count]

[List any remaining or new issues]
```

Repeat until clean or user approves remaining issues.

### Step 5: Update Spec Status

On successful review completion:
- Update spec status to "Implemented"
- Record review completion timestamp

## Session State

Update `.dev-flow-session.json`:

```json
{
  "currentPhase": 6,
  "phaseName": "Delivery",
  "phases": {
    "5_review": {
      "status": "completed",
      "output": {
        "iterations": 2,
        "issuesFound": [
          {
            "file": "path",
            "line": 45,
            "severity": "high",
            "issue": "description",
            "status": "fixed",
            "confidence": 85
          }
        ],
        "specStatusUpdated": true,
        "passedAt": "ISO-8601 timestamp"
      }
    }
  }
}
```

## Confidence Scoring

| Score  | Meaning               | Action       |
| ------ | --------------------- | ------------ |
| 0-25   | Likely false positive | Not reported |
| 26-50  | Might be issue        | Not reported |
| 51-75  | Probably real         | Not reported |
| 76-79  | Likely real           | Not reported |
| 80-100 | Definitely real       | **Reported** |

## Issue Categories

| Category       | Examples                                     |
| -------------- | -------------------------------------------- |
| **Bug**        | Logic errors, null handling, race conditions |
| **Security**   | Injection, XSS, auth bypass, data exposure   |
| **Convention** | Naming, structure, pattern violations        |
| **Quality**    | Duplication, complexity, missing tests       |

## Standalone Usage

When invoked directly:
1. Ask for files to review
2. Ask for spec/conventions context
3. Follow the process above
4. Offer to continue: "Would you like to proceed to delivery?"

## Additional Resources

### Reference Files

For confidence scoring criteria and review patterns:
- **`references/confidence-scoring.md`** - Detailed scoring guidelines and examples
