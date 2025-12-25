---
name: implementation
description: This skill should be used when the user asks to "implement the feature", "write the code", "create the implementation", "start coding", or mentions "implementation phase". Orchestrates parallel code and test implementation agents.
---

# Implementation Phase

Execute the implementation plan using parallel agents for code and tests. This phase transforms the specification into working code with comprehensive test coverage.

## Overview

The implementation phase:
- Launches parallel agents for code and tests
- Detects optional tools (swagger, postman)
- Verifies tests pass before proceeding
- Tracks all created and modified files

## Process

### Step 1: Detect Optional Tools

Check for available integrations:

```bash
# Check for swagger tools
which swag || which swagger-cli || ls swagger.json 2>/dev/null

# Check for Postman MCP (look for mcp__postman__ tools)
```

If detected, ask user:

```markdown
**Optional Tools Detected**

- [x] Swagger CLI found
- [ ] Postman integration available

Enable these for this feature?
1. Enable all detected
2. Select specific tools
3. Skip optional tools
```

Update session config accordingly.

### Step 2: Launch Parallel Agents

Launch both agents simultaneously using the Task tool:

**Agent 1: Code Implementation**
```
Task tool:
  subagent_type: "code-implementer"
  run_in_background: true
  prompt: |
    Implement the feature following the specification.

    Spec file: [path to spec]
    Architecture: [chosen option details]
    Conventions: [from discovery]

    Create/modify files as specified in the implementation checklist.
    Follow layer order: models → repository → service → handler → router
```

**Agent 2: Test Implementation**
```
Task tool:
  subagent_type: "test-implementer"
  run_in_background: true
  prompt: |
    Create tests for the feature.

    Spec file: [path to spec]
    Follow project testing conventions: [conventions]

    Create:
    - Unit tests for service layer
    - Integration tests for repository
    - API tests for endpoints

    Run tests after creation and report results.
```

### Step 3: Monitor Progress

Wait for both agents to complete:

```markdown
## Implementation Progress

**Code Implementation**: [status]
- Files created: [count]
- Files modified: [count]

**Test Implementation**: [status]
- Test files created: [count]
- Tests written: [count]
```

### Step 4: Verify Tests Pass

Run the project test suite:

```bash
# Detect and run test command
npm test || go test ./... || pytest || task test
```

Report results:

```markdown
## Test Results

**Total**: [count]
**Passed**: [count]
**Failed**: [count]

[If failures, list them with file:line references]
```

### Step 5: Optional - Swagger Regeneration

If `enableSwagger` is true, invoke the swagger skill to regenerate API documentation.

## Session State

Update `.dev-flow-session.json`:

```json
{
  "currentPhase": 5,
  "phaseName": "Review",
  "config": {
    "enableSwagger": true,
    "enablePostman": false
  },
  "phases": {
    "4_implementation": {
      "status": "completed",
      "output": {
        "filesCreated": ["paths"],
        "filesModified": ["paths"],
        "testsCreated": ["paths"],
        "testsStatus": {
          "total": 10,
          "passed": 10,
          "failed": 0
        },
        "swaggerRegenerated": true,
        "completedAt": "ISO-8601 timestamp"
      }
    }
  }
}
```

## Failure Handling

If tests fail:

1. Present failures with context
2. Offer to fix issues before proceeding
3. Re-run tests after fixes
4. Only proceed when all tests pass

## Standalone Usage

When invoked directly:
1. Ask for spec file location
2. Ask for project conventions
3. Follow the process above
4. Offer to continue: "Would you like to proceed to code review?"

## Additional Resources

### Reference Files

For implementation layer ordering and patterns:
- **`references/layer-order.md`** - Recommended implementation sequence by architecture type
