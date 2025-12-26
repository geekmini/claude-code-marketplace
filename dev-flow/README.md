# Dev Flow Plugin

A streamlined 6-phase feature development workflow with session management, parallel agents, and convention detection.

## Overview

This plugin guides you through the entire feature development lifecycle:

```
1. Discovery      → Understand feature + explore codebase conventions
2. Planning       → Clarify requirements + design architecture (3 options)
3. Specification  → Generate detailed spec document
4. Implementation → Parallel code + test agents
5. Review         → Interactive code review with confidence scoring
6. Delivery       → Documentation + commit + PR
```

## Installation

Add the marketplace:
```bash
/plugin marketplace add https://github.com/geekmini/claude-code-marketplace.git
```

Install the plugin:
```bash
/plugin install geekmini-claude-code-plugins@dev-flow
```

## Commands

### `/dev-flow:dev`

Start or resume the full 6-phase workflow.

```bash
/dev-flow:dev
/dev-flow:dev Add user authentication with OAuth2
```

Features:
- Session management with JSON state
- Resume from any phase
- Sequential code-first implementation (code → tests)
- Interactive code review

### `/dev-flow:resume`

Resume an interrupted session.

```bash
/dev-flow:resume
```

### `/dev-flow:status`

Check current session status.

```bash
/dev-flow:status
```

Options:
- Continue workflow
- View full session details
- Abandon and start fresh

## Skills (Standalone Use)

Each phase is available as a standalone skill that can be triggered by natural language:

| Skill | Triggers |
|-------|----------|
| `discovery` | "start a new feature", "explore the codebase" |
| `planning` | "plan the implementation", "design the architecture" |
| `specification` | "generate a spec", "create specification document" |
| `implementation` | "implement the feature", "write the code" |
| `review` | "review the code", "check for issues" |
| `delivery` | "create a PR", "commit changes" |

### Optional Skills

| Skill | Triggers |
|-------|----------|
| `swagger` | "regenerate swagger", "update API docs" |
| `postman` | "sync postman", "update postman collection" |

## Agents

The plugin includes specialized agents with optimized models for cost and speed:

| Agent | Model | Purpose |
|-------|-------|---------|
| `code-explorer` | Haiku | Fast codebase analysis and pattern discovery |
| `code-architect` | Sonnet | Design 3 implementation approaches |
| `code-reviewer` | Sonnet | Review code with confidence-based filtering |
| `code-implementer` | Sonnet | Implement production code |
| `test-implementer` | Sonnet | Create comprehensive tests |

**Performance optimization**: Using Haiku for exploration and Sonnet for implementation reduces costs by ~49% and improves speed by ~30% compared to using Opus for all agents.

## Session Management

Sessions are stored in `.claude/.dev-flow-session.json` (automatically gitignored).

### Session State
- Tracks current phase
- Stores all phase outputs
- Enables resume from any point
- Archives completed sessions

### Configuration
```json
{
  "config": {
    "enableSwagger": true,
    "enablePostman": false
  }
}
```

## Workflow Details

### Phase 1: Discovery

- Captures feature requirements
- Launches code-explorer agent
- Discovers project conventions
- Identifies similar features to reference

### Phase 2: Planning

- Asks clarifying questions one-by-one
- Covers: scope, data model, API, business rules
- Launches code-architect agent
- Presents 3 implementation options
- User selects preferred approach

### Phase 3: Specification

- Generates detailed spec document
- Includes: data model, API endpoints, business rules
- Implementation checklist
- User reviews and approves

### Phase 4: Implementation

- Detects optional tools (swagger, postman)
- Launches agents sequentially (code-first):
  1. code-implementer creates production code
  2. test-implementer writes tests with knowledge of actual implementation
- Verifies tests pass
- Optional: regenerates swagger docs

**Why sequential?** Tests can read actual implementation, resulting in higher quality coverage and fewer false failures.

### Phase 5: Review

- Launches code-reviewer agent
- Reports only high-confidence issues (>=80%)
- Interactive fix loop
- Re-reviews until clean
- Updates spec status to "Implemented"

### Phase 6: Delivery

- Updates project documentation (CLAUDE.md, README)
- Optional: syncs Postman collection
- Creates feature branch
- Commits with conventional format
- Creates PR using `gh` CLI
- Archives completed session

## File Structure

```
.claude/.dev-flow-session.json     # Active session (gitignored)
.claude/.dev-flow-sessions/        # Archived sessions
spec/[feature].md          # Generated specifications
```

## Convention Detection

The discovery phase auto-detects project conventions from:
- `CLAUDE.md` - Project guidelines
- `AGENTS.md` - Custom agents
- `README.md` - Project overview
- Existing code patterns

Detected conventions inform all subsequent phases.

## Requirements

- Claude Code CLI
- Git repository with remote
- `gh` CLI for PR creation (optional but recommended)

## Comparison with dev-workflow

This plugin (`dev-flow`) is a reimplementation of `dev-workflow` following official plugin best practices:

| Aspect | dev-workflow | dev-flow |
|--------|--------------|----------|
| Phases | 9 phases | 6 phases (consolidated) |
| Skills | Thin procedure lists | Rich skills with references |
| Agents | Generic descriptions | Proper `<example>` blocks |
| Agent models | All inherit (Opus) | Optimized (Haiku/Sonnet) |
| Session file | `.dev-workflow-session.json` | `.claude/.dev-flow-session.json` |

## License

MIT
