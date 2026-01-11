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
- `app_id`: 16-character hex hash of git remote URL (auto-injected by hook)

### PreToolUse Hook

The `validate-mem0-call.sh` hook automatically handles `app_id`:
- **Auto-injects `app_id`** when in a git repo (Claude doesn't need to specify it)
- Fixes invalid `app_id` values (repo names instead of hash)
- Safety fallback: converts `agent_id` to `app_id` if mistakenly used
- `updatedInput` must be at top level of response (NOT nested under `hookSpecificOutput`)
