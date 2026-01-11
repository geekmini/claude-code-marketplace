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

### How app_id Works

**SessionStart hook** provides the `app_id` at session start:
```
mem0: app_id="abc123..." for project-scoped memories
```

**The skill instructs Claude** to ALWAYS include this `app_id` in all mem0 tool calls.

**Note**: PreToolUse hook `updatedInput` does NOT work for MCP tools in Claude Code, so we rely on the skill to instruct Claude to include `app_id` manually.

### PreToolUse Hook (Fallback)

The `validate-mem0-call.sh` hook exists as a safety fallback but does not modify MCP tool inputs:
- Schema uses `decision: "approve"` and `hookSpecificOutput.updatedInput`
- Claude Code does not apply `updatedInput` for MCP tools (known limitation)
