---
description: Check the status of the current dev-flow session
---

# Dev-Flow Session Status

Display the current state of the feature development workflow.

## Session Check

```bash
cat .dev-flow-session.json 2>/dev/null || echo "NO_SESSION"
```

## If Session Exists

Parse session and display comprehensive status:

```markdown
## Dev-Flow Session Status

**Feature**: [featureName]
**Status**: [status]
**Started**: [createdAt]
**Last Updated**: [updatedAt]

### Phase Progress

| Phase | Name | Status |
|-------|------|--------|
| 1 | Discovery | [✅ Completed / ⏳ In Progress / ⬜ Pending] |
| 2 | Planning | [status] |
| 3 | Specification | [status] |
| 4 | Implementation | [status] |
| 5 | Review | [status] |
| 6 | Delivery | [status] |

### Current Phase: [currentPhase] - [phaseName]

[Details about current phase status]

### Key Outputs

**Discovery**:
- Feature: [featureName]
- Conventions: [summary]

**Planning** (if completed):
- Architecture: [chosen option]
- Questions answered: [count]

**Specification** (if completed):
- Spec file: [path]
- Status: [draft/approved/implemented]

**Implementation** (if completed):
- Files created: [count]
- Files modified: [count]
- Tests: [pass/fail status]

**Review** (if completed):
- Iterations: [count]
- Issues found: [count]
- Issues fixed: [count]

### Configuration

- Swagger: [enabled/disabled]
- Postman: [enabled/disabled]
```

## Options

Present available actions:

```
What would you like to do?

1. **Continue** - Resume from current phase
2. **View details** - Show full session data
3. **Abandon** - Archive session and start fresh
```

### If Continue

Invoke `/dev-flow:resume` to continue the workflow.

### If View Details

Display raw session JSON in formatted code block.

### If Abandon

Archive the session:

```bash
mkdir -p .dev-flow-sessions
mv .dev-flow-session.json ".dev-flow-sessions/[feature]-abandoned-$(date +%Y%m%d-%H%M%S).json"
```

Confirm:
```
Session archived. Ready to start a new feature with /dev-flow:dev
```

## If No Session

```
## No Active Session

No dev-flow session is currently active.

### Recent Sessions

[List files in .dev-flow-sessions/ if directory exists]

### Start New

To begin feature development:
> /dev-flow:dev [feature description]
```

## Archived Sessions

If `.dev-flow-sessions/` exists, list recent sessions:

```bash
ls -la .dev-flow-sessions/ 2>/dev/null | tail -5
```

Offer to view or restore archived sessions if any exist.
