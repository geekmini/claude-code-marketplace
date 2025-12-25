# Code Review Guidelines

## Core Principles

- Focus on actionable feedback that improves code health
- Balance critical feedback with non-blocking suggestions (use "Nit:" prefix)
- Technical facts and data override personal opinions
- Be direct and concise
- If code is fine, don't comment; silence means approval

## Review Process

1. **Understand the Change**
   - Read the PR description
   - Understand what problem this code solves
   - Consider the broader context

2. **Evaluate Code Health**
   - Does this make the system easier or harder to maintain?
   - Is the code more readable than before?
   - Does it follow established patterns?
   - Are there obvious bugs or edge cases not handled?

## Focus Areas

### Design & Architecture
- Does the code fit with overall system design?
- Are there better architectural approaches?
- Is separation of concerns followed?

### Functionality
- Does the code do what the author intended?
- Are there edge cases not handled?
- Is error handling appropriate?

### Complexity
- Can other developers understand this code quickly?
- Is the code over-engineered?
- Should any code be broken into smaller functions?

### Tests
- Are there appropriate tests for new functionality?
- Do tests cover error cases and edge cases?

### Naming & Style
- Are variables, functions, and classes named clearly?
- Does code follow existing patterns in the codebase?

## Critical vs Suggestions

**Critical (must fix):**
- Bugs that will cause failures
- Security vulnerabilities
- Code that worsens code health
- Violations of architectural principles

**Suggestions (prefix with "Nit:"):**
- Minor style inconsistencies
- Alternative approaches
- Educational comments
- Optional refactoring ideas
