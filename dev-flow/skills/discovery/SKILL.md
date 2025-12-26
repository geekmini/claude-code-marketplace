---
name: discovery
description: This skill should be used when the user asks to "start a new feature", "understand codebase conventions", "explore the codebase", "begin feature development", or mentions "discovery phase". Combines requirement gathering with codebase exploration to inform implementation.
---

# Discovery Phase

Capture the feature request and explore codebase conventions in a single unified phase. This phase establishes the foundation for all subsequent development by understanding both what needs to be built and how the codebase expects it to be built.

## Overview

The discovery phase combines two critical activities:
1. **Requirement Gathering** - Understand what the user wants to build
2. **Codebase Exploration** - Discover project conventions and patterns

## Process

### Step 1: Capture the Feature Request

Listen to the user's description and extract key information:

- **Feature Name**: Short, descriptive kebab-case name
- **Description**: 1-2 sentence summary
- **Problem Solved**: What user need does this address
- **Initial Constraints**: Any mentioned limitations

Ask clarifying questions if unclear:
- "What is the main goal of this feature?"
- "Who will use this feature?"
- "Are there any must-have requirements?"

### Step 2: Launch Code Explorer Agent

Use the Task tool to launch the code-explorer agent:

```
Task tool parameters:
  subagent_type: "dev-flow:code-explorer"
  prompt: |
    Explore the codebase to understand conventions for implementing: [feature]

    1. Check for CLAUDE.md, AGENTS.md, README.md
    2. Extract architecture style, naming conventions, testing patterns
    3. Find similar features already implemented
    4. Identify patterns to follow

    Output a structured summary with:
    - Architecture style
    - Naming conventions
    - Testing patterns
    - Similar features found
    - Key files to reference
```

**Note**: Use fully qualified agent name `dev-flow:code-explorer`.

### Step 3: Present Discovery Summary

Combine findings into a structured summary:

```markdown
## Discovery Summary

**Feature**: [name]
**Description**: [summary]

### Goals
- [Goal 1]
- [Goal 2]

### Initial Requirements
- [Requirement 1]
- [Requirement 2]

### Project Conventions
- **Architecture**: [style found]
- **Naming**: [conventions]
- **Testing**: [framework and patterns]

### Similar Features
- [Feature]: [what to reuse]

### Key Files to Reference
1. `path/to/file.ext` - [purpose]

Does this capture your intent correctly?
```

## Session State

Update `.claude/.dev-flow-session.json` with discovery output:

```json
{
  "currentPhase": 2,
  "phaseName": "Planning",
  "phases": {
    "1_discovery": {
      "status": "completed",
      "output": {
        "featureName": "string",
        "description": "string",
        "goals": ["array"],
        "initialRequirements": ["array"],
        "constraints": ["array"],
        "conventions": {},
        "patterns": [],
        "similarFeatures": []
      }
    }
  }
}
```

## Standalone Usage

When invoked directly (not from /dev-flow:dev):

1. Ask user to describe their feature idea
2. Follow the process above
3. Offer to start the full workflow: "Would you like to continue with the planning phase?"

## Additional Resources

### Reference Files

For detailed convention discovery guidance, consult:
- **`references/conventions-checklist.md`** - Comprehensive checklist for exploring codebases
