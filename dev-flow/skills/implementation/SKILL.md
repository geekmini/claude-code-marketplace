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

### Step 2: Launch Parallel Agents (MANDATORY)

**CRITICAL: You MUST use the Task tool to launch subagents. DO NOT implement code directly.**

Before launching agents, read the session file to get context:

```bash
cat .claude/.dev-flow-session.json
```

Extract these values from the session:
- `specPath`: from `phases.3_specification.output.specPath`
- `chosenOption`: from `phases.2_planning.output.chosenOption`
- `filesToCreate`: from `phases.2_planning.output.filesToCreate`
- `filesToModify`: from `phases.2_planning.output.filesToModify`
- `conventions`: from `phases.1_discovery.output.conventions`
- `checklist`: from `phases.3_specification.output.implementationChecklist`

**Launch BOTH agents in a SINGLE message with TWO parallel Task tool calls:**

**Agent 1: code-implementer**
```
Task tool parameters:
  subagent_type: "dev-flow:code-implementer"
  run_in_background: true
  prompt: |
    Implement the feature following the specification.

    ## Specification
    Read the spec file at: {specPath}

    ## Architecture Decision
    User chose: {chosenOption}

    Files to create:
    {filesToCreate as bullet list}

    Files to modify:
    {filesToModify as bullet list}

    ## Conventions
    - Architecture: {conventions.architecture}
    - Naming: {conventions.naming}
    - Error handling: {conventions.errorHandling}

    ## Implementation Checklist
    {checklist as numbered list}

    ## Layer Order
    Implement in this order: models → repository → service → handler → router

    ## Done Criteria
    - All checklist items completed
    - Code compiles without errors
    - No linting errors
```

**Agent 2: test-implementer (IN THE SAME MESSAGE)**
```
Task tool parameters:
  subagent_type: "dev-flow:test-implementer"
  run_in_background: true
  prompt: |
    Create comprehensive tests for the feature.

    ## Specification
    Read the spec file at: {specPath}

    ## Test Conventions
    - Framework: {conventions.testing}
    - Structure: {conventions.testStructure}

    ## Required Tests
    - Unit tests for service/business logic
    - Integration tests for repository/database
    - API/E2E tests for endpoints

    ## Test Scenarios from Spec
    {extract test scenarios from spec}

    ## Done Criteria
    - All spec requirements have test coverage
    - Tests include happy path, edge cases, error cases
    - All tests pass when run
```

**ENFORCEMENT:**
- Use FULLY QUALIFIED names: `dev-flow:code-implementer`, `dev-flow:test-implementer`
- Send BOTH Task calls in ONE message (enables true parallelism)
- DO NOT write implementation code yourself - delegate to agents
- If Task tool fails, report the error - do not fall back to implementing yourself

### Step 3: Wait for Agents and Collect Results

After launching, wait for both agents using TaskOutput:

```
TaskOutput(task_id: {code_agent_task_id}, block: true)
TaskOutput(task_id: {test_agent_task_id}, block: true)
```

Collect and present results:

```markdown
## Implementation Progress

**Code Implementation**: ✅ Complete
- Files created: {list from agent output}
- Files modified: {list from agent output}

**Test Implementation**: ✅ Complete
- Test files created: {list from agent output}
- Tests written: {count}
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

Update `.claude/.dev-flow-session.json`:

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
