---
description: Resume an interrupted dev-flow session from the last saved phase
---

# Resume Dev-Flow Session

Continue the feature development workflow from where it was interrupted.

## Session Check

```bash
cat .dev-flow-session.json 2>/dev/null || echo "NO_SESSION"
```

## If Session Exists

Read the session file and extract:
- `featureName` - The feature being developed
- `currentPhase` - Phase number to resume from
- `phaseName` - Human-readable phase name
- `status` - Session status (should be "in_progress")
- `phases` - All completed phase outputs

Present session summary:

```
## Resuming Dev-Flow Session

**Feature**: [featureName]
**Current Phase**: [currentPhase] - [phaseName]
**Status**: [status]

### Completed Phases
[List completed phases with key outputs]

### Ready to Continue
Resuming from [phaseName] phase...
```

## Resume from Phase

Based on `currentPhase`, continue with the appropriate skill:

| Phase | Skill | Context Needed |
|-------|-------|----------------|
| 1 | discovery | None - starting fresh |
| 2 | planning | Discovery output |
| 3 | specification | Discovery + Planning output |
| 4 | implementation | Spec file path, chosen architecture |
| 5 | review | Implementation files list |
| 6 | delivery | All prior phase outputs |

## Context Loading

For each phase, load required context from session:

**Phase 2 (Planning)**:
- Load `phases.1_discovery.output` for feature context
- Continue with clarifying questions

**Phase 3 (Specification)**:
- Load discovery and planning outputs
- Generate or update spec document

**Phase 4 (Implementation)**:
- Load spec file path from `phases.3_specification.output.specFile`
- Load architecture from `phases.2_planning.output.chosen`
- Resume parallel agent execution

**Phase 5 (Review)**:
- Load implementation files from `phases.4_implementation.output`
- Continue review loop

**Phase 6 (Delivery)**:
- Load all prior outputs
- Continue with documentation, commit, PR

## If No Session

```
No active dev-flow session found.

To start a new feature development workflow:
> /dev-flow:dev [feature description]

Or describe the feature you want to build.
```

## Error Recovery

If session file is corrupted or invalid:

1. Attempt to parse JSON
2. If parsing fails, offer options:
   - View raw session file
   - Archive corrupted session and start fresh
   - Manually specify phase to resume from
