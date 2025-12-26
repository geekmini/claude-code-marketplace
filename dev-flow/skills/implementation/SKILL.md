---
name: implementation
description: This skill should be used when the user asks to "implement the feature", "write the code", "create the implementation", "start coding", or mentions "implementation phase". Orchestrates sequential code-first implementation with test agents.
---

# Implementation Phase

Execute the implementation plan using sequential agents: code first, then tests. This approach ensures tests can reference actual implementation for higher quality coverage.

## Overview

The implementation phase:
- Launches code-implementer agent first
- Then launches test-implementer with knowledge of created files
- Detects optional tools (swagger, postman)
- Verifies tests pass before proceeding
- Tracks all created and modified files

**Why sequential (code → tests)?**
- Tests can READ actual implementation before being written
- Catches untestable code immediately
- Test failures indicate real bugs, not spec mismatches
- Higher quality test coverage

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

### Step 2: Launch Code Implementation Agent (FIRST)

**CRITICAL: You MUST use the Task tool to launch subagents. DO NOT implement code directly.**

Before launching, read the session file to get context:

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

**Launch code-implementer agent:**
```
Task tool parameters:
  subagent_type: "dev-flow:code-implementer"
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

    ## Output Required
    Return a list of:
    - Files created (with paths)
    - Files modified (with paths)
```

**Wait for completion and collect results:**

Store the agent output:
- `filesCreated`: list of created file paths
- `filesModified`: list of modified file paths

Present progress:
```markdown
## Code Implementation: ✅ Complete

**Files Created**:
{list filesCreated}

**Files Modified**:
{list filesModified}

Proceeding to test implementation...
```

### Step 3: Launch Test Implementation Agent (AFTER code completes)

**Now launch test-implementer with knowledge of the implementation:**

```
Task tool parameters:
  subagent_type: "dev-flow:test-implementer"
  prompt: |
    Create comprehensive tests for the feature.

    ## Specification
    Read the spec file at: {specPath}

    ## Implementation Files (READ THESE FIRST)
    The following files were just created/modified. Read them to understand the actual implementation:

    Files created:
    {filesCreated from Step 2}

    Files modified:
    {filesModified from Step 2}

    ## Test Conventions
    - Framework: {conventions.testing}
    - Structure: {conventions.testStructure}

    ## Required Tests
    - Unit tests for service/business logic
    - Integration tests for repository/database
    - API/E2E tests for endpoints

    ## Instructions
    1. Read the implementation files first
    2. Write tests that verify the ACTUAL implementation behavior
    3. Cover happy paths, edge cases, and error scenarios
    4. Run tests and report results

    ## Done Criteria
    - All implementation files have corresponding tests
    - Tests cover happy path, edge cases, error cases
    - All tests pass when run
```

**Wait for completion and collect results:**

```markdown
## Test Implementation: ✅ Complete

**Test Files Created**:
{list from agent output}

**Tests Written**: {count}
```

**ENFORCEMENT:**
- Use FULLY QUALIFIED names: `dev-flow:code-implementer`, `dev-flow:test-implementer`
- Run agents SEQUENTIALLY: code first, then tests
- Pass implementation file list to test agent
- DO NOT write code yourself - delegate to agents
- If Task tool fails, report the error - do not fall back to implementing yourself

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
