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
- `app_id`: 16-character hex hash of git remote URL (for project-scoped memories)
- Use `app_id` (NOT `agent_id`) for project-level memories

### PreToolUse Hook

The `validate-mem0-call.sh` hook auto-fixes incorrect mem0 API calls:
- Replaces `agent_id` with `app_id`
- Replaces invalid `app_id` (repo names) with correct hash
- `updatedInput` must be at top level of response (NOT nested under `hookSpecificOutput`)
