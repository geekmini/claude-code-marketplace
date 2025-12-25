---
name: planning
description: This skill should be used when the user asks to "plan the implementation", "design the architecture", "clarify requirements", "propose solutions", or mentions "planning phase". Combines requirement clarification with architecture design.
---

# Planning Phase

Clarify requirements through targeted questions and design implementation approaches. This phase ensures alignment on what to build before writing any code.

## Overview

The planning phase combines two activities:
1. **Requirement Clarification** - Ask targeted questions to fill gaps
2. **Architecture Design** - Propose 3 implementation options

## Process

### Step 1: Prepare Questions

Based on discovery output, identify gaps in these categories:

| Category | Example Questions |
|----------|-------------------|
| **Scope** | What's included/excluded? |
| **Data Model** | Fields, types, required/optional? |
| **API Design** | Endpoints, methods, request/response? |
| **Business Rules** | Validation, constraints, edge cases? |
| **Authentication** | Public or protected endpoints? |
| **Error Handling** | What can go wrong, how to handle? |

### Step 2: Ask Questions One-by-One

Present questions individually, waiting for each answer before proceeding:

```markdown
**Question 1 of N**: [Category]

[Clear, specific question]

Options (if applicable):
1. [Option A]
2. [Option B]
3. Other (please specify)
```

### Step 3: Launch Architecture Agent

Use the Task tool:

```
Task tool:
  subagent_type: "code-architect"
  prompt: |
    Design architecture for: [feature name]

    Context from discovery:
    [conventions, patterns, similar features]

    Requirements from clarification:
    [data model, endpoints, business rules]

    Provide 3 implementation approaches:
    - Option A: Minimal changes (fastest, max reuse)
    - Option B: Clean architecture (best design)
    - Option C: Pragmatic balance

    For each: files to create/modify, pros, cons
    Include a recommendation.
```

### Step 4: Present Options

Show all 3 architecture options with clear trade-offs:

```markdown
## Architecture Options

### Option A: [Name]
**Description**: [approach summary]

**Files to Create**:
- `path/to/file.ext` - [purpose]

**Files to Modify**:
- `path/to/file.ext` - [changes]

**Pros**: [list]
**Cons**: [list]

---

### Option B: [Name]
[Same structure]

---

### Option C: [Name]
[Same structure]

---

## Recommendation
I recommend **Option [X]** because: [reasons]

Which option would you like to proceed with?
```

### Step 5: Get User Selection

Record the chosen option and rationale.

## Session State

Update `.dev-flow-session.json`:

```json
{
  "currentPhase": 3,
  "phaseName": "Specification",
  "phases": {
    "2_planning": {
      "status": "completed",
      "output": {
        "clarifications": [
          {"question": "string", "answer": "string", "category": "string"}
        ],
        "dataModel": {},
        "endpoints": [],
        "businessRules": [],
        "architectureOptions": [],
        "chosen": "Option B",
        "rationale": "string"
      }
    }
  }
}
```

## Approval Gate

Before proceeding to specification:

```markdown
## Planning Complete

**Requirements Clarified**: [count] questions answered
**Architecture Selected**: [chosen option]

Do you approve these requirements and architecture to proceed to specification?
```

## Standalone Usage

When invoked directly:
1. Ask for context (feature description, any prior exploration)
2. Follow the process above
3. Offer to continue: "Would you like to generate the specification?"

## Additional Resources

### Reference Files

For detailed question categories and examples:
- **`references/question-categories.md`** - Comprehensive question bank by category
