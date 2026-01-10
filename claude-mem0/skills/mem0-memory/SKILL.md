---
name: mem0 Memory Management
description: This skill should be used when the user asks about "memory", "remember this", "what do you know about me", "recall", "forget this", "search memories", "save preference", or when Claude needs guidance on using mem0 tools effectively. Provides best practices for memory storage, retrieval, and organization.
version: 0.1.0
---

# mem0 Memory Management

Guidance for effectively using mem0 memory tools to provide personalized, context-aware assistance across sessions.

## Overview

mem0 provides persistent memory storage with these key capabilities:
- **Add memories**: Store user preferences, project learnings, decisions
- **Search memories**: Retrieve relevant context using semantic search
- **Organize memories**: Scope by user (global) or project (app_id)
- **Manage memories**: Update, delete, or list stored memories

## Available MCP Tools

The mem0 MCP server provides these tools:

| Tool | Purpose |
|------|---------|
| `add_memory` | Store new memories with scoping |
| `search_memories` | Semantic search across memories |
| `get_memories` | List memories with filters |
| `get_memory` | Retrieve single memory by ID |
| `update_memory` | Modify existing memory |
| `delete_memory` | Remove single memory |
| `delete_all_memories` | Bulk delete by scope |

## Memory Scoping Strategy

### Global Memories (User-Level)

Store cross-project preferences and personal information.

**Scope**: Use `user_id` only

**What to store**:
- Coding style preferences (formatting, naming conventions)
- Technology preferences (frameworks, tools, libraries)
- Communication preferences (verbosity, explanation depth)
- Personal information shared (name, role, expertise)
- Workflow preferences (commit style, review process)

**Example**:
```
add_memory(
  messages="User prefers TypeScript over JavaScript and uses 2-space indentation",
  user_id="james"
)
```

### Project Memories (Project-Level)

Store codebase-specific knowledge and decisions.

**Scope**: Use `user_id` + `app_id`

**What to store**:
- Architecture decisions and rationale
- Codebase patterns and conventions
- Important file locations and purposes
- Bug fixes and their root causes
- Configuration details and setup steps
- Dependencies and integration notes

**Example**:
```
add_memory(
  messages="The API uses Express with middleware chain: auth -> validate -> handler",
  user_id="james",
  app_id="abc123def456"
)
```

## When to Search Memories

Search for relevant context when:
- Starting a new session (automatic via SessionStart hook)
- User asks about past decisions or preferences
- Working on tasks similar to previous work
- User mentions something that might have been discussed before
- Needing context about the project structure

**Search strategy**:
1. Start with specific queries related to the current task
2. Search both global and project-scoped memories
3. Include relevant context in responses without overwhelming the user

## When to Add Memories

Add memories when discovering information that is:
- **Reusable**: Will be valuable in future sessions
- **Non-obvious**: Not easily rediscovered from code or docs
- **Stable**: Unlikely to change frequently
- **Personal**: Specific to this user or project

**Skip adding** when:
- Information is trivial or temporary
- Already documented in codebase (README, comments)
- Easily discoverable through code exploration
- User explicitly marks content as private

## Memory Content Guidelines

### Writing Effective Memories

**Be concise**: One clear fact or preference per memory
```
Good: "User prefers verbose error messages with stack traces"
Bad: "The user said they want more information when there's an error, specifically they mentioned wanting to see the full stack trace and maybe some context about what was happening"
```

**Be specific**: Include concrete details
```
Good: "Project uses PostgreSQL 15 with TimescaleDB extension for time-series data"
Bad: "Project uses a database"
```

**Include context**: Explain why, not just what
```
Good: "Authentication uses JWT with 24h expiry - chosen for stateless API design"
Bad: "Uses JWT"
```

### Categories of Memories

**User preferences**: How the user likes to work
- Code style, formatting preferences
- Explanation depth preferences
- Tool and technology preferences

**Project knowledge**: What makes this codebase unique
- Architecture patterns and design decisions
- Key abstractions and their purposes
- Integration points and dependencies

**Historical context**: What happened and why
- Bug fixes with root cause analysis
- Refactoring decisions and rationale
- Feature implementations and trade-offs

## Memory Lifecycle

### Creation
- Add memories immediately when valuable information surfaces
- Scope appropriately (global vs project)
- Write clear, searchable content

### Retrieval
- Search at session start for relevant context
- Search during tasks when past context would help
- Combine global and project memories for full picture

### Updates
- Update memories when information becomes outdated
- Prefer updating to creating duplicates
- Preserve historical context when relevant

### Deletion
- Delete outdated or incorrect memories
- Remove duplicates
- Clean up temporary or no-longer-relevant memories

## Privacy Considerations

**Respect user privacy**:
- Never store credentials, API keys, or secrets
- Don't store content explicitly marked private
- Be cautious with personal information
- Ask before storing sensitive business information

**User control**:
- Users can request to see stored memories
- Users can request deletion of specific memories
- Users can opt out of automatic memory capture

## Integration with Hooks

This plugin uses hooks for automatic memory management:

**SessionStart**: Automatically searches and surfaces relevant memories
**Stop**: Prompts to capture learnings from completed tasks
**SessionEnd**: Prompts to capture session-level summaries

The hooks handle routine memory operations. Use manual memory tools for:
- Explicit user requests ("remember this", "forget that")
- Immediate capture of important information
- Memory maintenance (updates, deletions)

## Troubleshooting

**No memories found**:
- Verify user_id is configured correctly
- Check if searching correct scope (global vs project)
- Try broader search queries

**Too many irrelevant results**:
- Use more specific search queries
- Add filters (app_id for project-specific)
- Consider cleaning up old memories

**Duplicate memories**:
- Search before adding to check for existing
- Use update_memory for modifications
- Periodically clean up duplicates

## Quick Reference

| Goal | Tool | Scope |
|------|------|-------|
| Store user preference | `add_memory` | user_id only |
| Store project knowledge | `add_memory` | user_id + app_id |
| Find past decisions | `search_memories` | user_id + app_id |
| Get user preferences | `search_memories` | user_id only |
| Update outdated info | `update_memory` | Existing memory ID |
| Remove incorrect info | `delete_memory` | Memory ID |
