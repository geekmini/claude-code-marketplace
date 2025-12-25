---
description: Start or resume a 6-phase feature development workflow with session management and parallel agents
argument-hint: [optional: feature description]
---

# Feature Development Workflow

Execute the complete 6-phase development workflow from discovery to PR creation.

## Workflow Phases

```
1. Discovery      → Understand feature + explore codebase
2. Planning       → Clarify requirements + design architecture
3. Specification  → Generate detailed spec document
4. Implementation → Parallel code + test agents
5. Review         → Interactive code review loop
6. Delivery       → Documentation + commit + PR
```

## Session Management

### Check for Existing Session

```bash
ls .dev-flow-session.json 2>/dev/null
```

### If Session Exists

Read the session file and present options:

```
Found existing dev-flow session:
- Feature: [featureName]
- Current Phase: [currentPhase] - [phaseName]
- Last Updated: [updatedAt]

Options:
1. Resume this session (continue from current phase)
2. Start fresh (archives existing session)
```

**If Resume**: Continue from the current phase.
**If Start fresh**: Archive to `.dev-flow-sessions/[feature]-[timestamp].json` and create new session.

### If No Session

If $ARGUMENTS provided, use as initial feature description.
Otherwise, ask user to describe the feature they want to build.

### Ensure Gitignore

Check if `.gitignore` contains dev-flow entries. If not, add:

```gitignore
# Dev Flow Plugin
.dev-flow-session.json
.dev-flow-sessions/
```

## Phase Execution

Execute each phase in sequence, updating session state after each phase completes.

### Phase 1: Discovery

Use the discovery skill to:
1. Capture feature requirements from user
2. Launch code-explorer agent to analyze codebase
3. Present discovery summary

Update session:
- Set `currentPhase: 2`, `phaseName: "Planning"`
- Store discovery output

### Phase 2: Planning

Use the planning skill to:
1. Ask clarifying questions one-by-one
2. Launch code-architect agent for 3 options
3. Get user selection

Update session:
- Set `currentPhase: 3`, `phaseName: "Specification"`
- Store planning output including chosen architecture

### Phase 3: Specification

Use the specification skill to:
1. Generate detailed spec document
2. Get user approval

Update session:
- Set `currentPhase: 4`, `phaseName: "Implementation"`
- Store spec file path and approval

### Phase 4: Implementation

Use the implementation skill to:
1. Detect optional tools (swagger, postman)
2. Launch code-implementer and test-implementer agents in parallel
3. Verify tests pass

Update session:
- Set `currentPhase: 5`, `phaseName: "Review"`
- Store implementation output

### Phase 5: Review

Use the review skill to:
1. Launch code-reviewer agent
2. Interactive fix loop until clean or approved
3. Update spec status to "Implemented"

Update session:
- Set `currentPhase: 6`, `phaseName: "Delivery"`
- Store review output

### Phase 6: Delivery

Use the delivery skill to:
1. Update project documentation
2. Create feature branch, commit, push
3. Create pull request
4. Archive completed session

Present completion summary with PR link.

## Tips

- Each phase has an approval gate before proceeding
- Use `/dev-flow:status` to check progress at any time
- Use `/dev-flow:resume` to continue after interruption
- Session state is saved after each phase
