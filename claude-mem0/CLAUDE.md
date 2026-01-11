# Claude Code Instructions for claude-mem0

## Release Process

**IMPORTANT: Always bump the plugin version when making changes.**

Before committing changes to this plugin:
1. Update the version in `.claude-plugin/plugin.json`
2. Use semantic versioning:
   - PATCH (x.x.X): Bug fixes, minor improvements
   - MINOR (x.X.0): New features, non-breaking changes
   - MAJOR (X.0.0): Breaking changes

## Project Structure

- `.claude-plugin/plugin.json` - Plugin manifest with version
- `hooks/hooks.json` - Hook configuration
- `hooks/scripts/` - Hook implementation scripts
- `scripts/` - Utility scripts (e.g., get-app-id.sh)
- `skills/` - Skill definitions
- `.mcp.json` - MCP server configuration

## Key Implementation Details

### Memory Scoping

- `user_id`: Set via `MEM0_USER_ID` environment variable
- `app_id`: 16-character hex hash of git remote URL

### Two-Stage Scope Detection (v1.6.0+)

Claude determines memory scope using natural language understanding:

1. **Stage 1 - Explicit Signals**: Check for keywords like "globally", "this project", "I prefer"
2. **Stage 2 - Content Analysis**: Analyze if content is personal preference vs project-specific
3. **Default**: User-scoped (no app_id) when ambiguous

**User-scoped (NO app_id)**: Personal preferences, coding style, tool preferences
**Project-scoped (WITH app_id)**: Architecture decisions, file locations, project dependencies

### SessionStart Hook

Provides `app_id` at session start (informational, not directive):
```
[mem0] app_id="abc123..." available for project-scoped memories
```

Claude decides when to use it based on user intent.

### PreToolUse Hook (Fallback)

The `validate-mem0-call.sh` hook exists as a safety fallback but does not modify MCP tool inputs:
- Claude Code does not apply `updatedInput` for MCP tools (known limitation)
- Hook schema uses `decision: "approve"` and `hookSpecificOutput.updatedInput`
