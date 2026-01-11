---
name: mem0 Memory Management
description: This skill should be used when the user asks about "memory", "remember this", "what do you know about me", "recall", "forget this", "search memories", "save preference", or when Claude needs guidance on using mem0 tools effectively. Provides best practices for memory storage, retrieval, and organization.
version: 0.1.0
---

# mem0 Memory Management

Guidance for effectively using mem0 memory tools to provide personalized, context-aware assistance across sessions.

## CRITICAL: Project Scoping with app_id

**You MUST always include `app_id` when calling mem0 tools in a git repository.**

At session start, you receive a message like:
```
mem0: app_id="abc123def456..." for project-scoped memories
```

**ALWAYS use this exact `app_id` value in ALL mem0 tool calls:**

```
add_memory(text="...", app_id="abc123def456...")
search_memories(query="...", app_id="abc123def456...")
get_memories(app_id="abc123def456...")
```

**Rules:**
- If `app_id` was provided at session start → ALWAYS include it in every mem0 call
- If no `app_id` was provided (not in git repo) → omit `app_id` for global memories
- NEVER omit `app_id` when it was provided - this causes memories to be stored globally instead of project-scoped

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

Store cross-project preferences and personal information. Only use when NOT in a git repo (no app_id provided).

**What to store**:
- Coding style preferences (formatting, naming conventions)
- Technology preferences (frameworks, tools, libraries)
- Communication preferences (verbosity, explanation depth)
- Personal information shared (name, role, expertise)

**Example** (only when no app_id at session start):
```
add_memory(text="User prefers TypeScript over JavaScript and uses 2-space indentation")
```

### Project Memories (Project-Level)

Store codebase-specific knowledge and decisions. **This is the default when app_id is provided.**

**What to store**:
- Architecture decisions and rationale
- Codebase patterns and conventions
- Important file locations and purposes
- Bug fixes and their root causes
- Configuration details and setup steps
- Dependencies and integration notes

**Example** (use the app_id from session start):
```
add_memory(
  text="The API uses Express with middleware chain: auth -> validate -> handler",
  app_id="abc123def456..."
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

This plugin uses hooks:

**SessionStart**: Provides the `app_id` hash for project-scoped memories. Look for the message:
```
mem0: app_id="..." for project-scoped memories
```
You MUST use this app_id in all subsequent mem0 tool calls.

**Stop**: Reminder to capture learnings from completed tasks
**SessionEnd**: Reminder to capture session-level summaries

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

**Remember: If app_id was provided at session start, ALWAYS include it in every call.**

| Goal | Tool | Include app_id? |
|------|------|-----------------|
| Store project knowledge | `add_memory` | YES (from session start) |
| Find project decisions | `search_memories` | YES (from session start) |
| Store global preference | `add_memory` | NO (only if no app_id provided) |
| Find global preferences | `search_memories` | NO (only if no app_id provided) |
| Update memory | `update_memory` | Use memory_id |
| Delete memory | `delete_memory` | Use memory_id |
