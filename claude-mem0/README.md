# claude-mem0

Persistent memory for Claude Code using [mem0](https://mem0.ai) cloud API. Automatically captures and retrieves global user-level and project-level memories to provide personalized, context-aware assistance across sessions.

## Features

- **Automatic memory retrieval** at session start
- **Automatic memory capture** on task completion and session end
- **Global memories** for user preferences (persists across all projects)
- **Project memories** for codebase-specific knowledge
- **Semantic search** for relevant context
- **Cloud-based storage** via mem0 API (no local database)

## Prerequisites

1. **mem0 API Key**: Get one from [mem0.ai](https://app.mem0.ai)
2. **uv** (Python package manager): Install with `curl -LsSf https://astral.sh/uv/install.sh | sh`

## Installation

1. Install the plugin:
   ```bash
   /plugin install claude-mem0
   ```

2. Add environment variables to your shell profile (`~/.zshrc` or `~/.bashrc`):
   ```bash
   # Required: mem0 API key (get from https://app.mem0.ai/dashboard/api-keys)
   export MEM0_API_KEY="m0-your-api-key-here"

   # Required: Your unique user identifier for memories
   export MEM0_USER_ID="your-username"
   ```

3. Reload your shell and restart Claude Code:
   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

## Configuration

All configuration is done via environment variables:

| Variable | Required | Description | Default |
|----------|----------|-------------|---------|
| `MEM0_API_KEY` | Yes | Your mem0 API key | - |
| `MEM0_USER_ID` | Yes | Your unique identifier for memories | `$USER` |

## How It Works

### Memory Scoping

| Scope | Identifier | Use Case |
|-------|------------|----------|
| **Global** | `user_id` only | User preferences, coding style, personal info |
| **Project** | `user_id` + `app_id` | Architecture, patterns, project-specific knowledge |

Project ID is automatically derived from your git remote URL (SHA-256 hash), ensuring consistent identification across clones.

### Automatic Hooks

| Hook | Trigger | Action |
|------|---------|--------|
| **SessionStart** | Session begins | Search and surface relevant memories |
| **Stop** | Task completes | Prompt to capture learnings |
| **SessionEnd** | Session ends | Prompt to capture session summary |

### MCP Tools

The plugin configures the official [mem0-mcp-server](https://github.com/mem0ai/mem0-mcp) which provides:

- `add_memory` - Store new memories
- `search_memories` - Semantic search
- `get_memories` - List with filters
- `get_memory` - Get by ID
- `update_memory` - Modify existing
- `delete_memory` - Remove by ID
- `delete_all_memories` - Bulk delete

## Usage Examples

### Manual Memory Operations

**Save a preference:**
> "Remember that I prefer TypeScript over JavaScript"

**Recall information:**
> "What do you know about my coding preferences?"

**Search project history:**
> "What decisions have we made about the authentication system?"

**Forget something:**
> "Forget what I told you about my email address"

### Automatic Capture

The plugin automatically captures:
- User preferences discovered during tasks
- Project architecture decisions
- Bug fixes and their root causes
- Important codebase patterns

## Privacy

- Memories are stored in your mem0 cloud account
- Never stores credentials, API keys, or secrets
- Content marked as `<private>` is excluded
- You can delete memories at any time

## Troubleshooting

### MCP Server Not Starting

Ensure `uvx` is available:
```bash
which uvx
# If not found, install uv:
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### No Memories Found

1. Check your `MEM0_API_KEY` is set correctly
2. Verify `MEM0_USER_ID` matches what was used to store memories
3. For project memories, ensure you're in a git repo with a remote

### Debug Mode

Run Claude Code with debug output:
```bash
claude --debug
```

Look for:
- MCP server initialization
- Hook execution
- Memory tool calls

## Architecture

```
claude-mem0/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── .mcp.json                 # MCP server config (mem0-mcp-server)
├── hooks/
│   ├── hooks.json            # Hook configuration
│   ├── scripts/
│   │   └── on-session-start.sh   # Memory retrieval
│   └── prompts/
│       ├── on-stop.md            # Task capture prompt
│       └── on-session-end.md     # Session summary prompt
├── skills/
│   └── mem0-memory/
│       └── SKILL.md          # Memory best practices
├── scripts/
│   └── get-project-id.sh     # Git remote hash utility
└── README.md
```

## License

MIT

## Credits

- [mem0](https://mem0.ai) - Memory layer for AI
- [mem0-mcp-server](https://github.com/mem0ai/mem0-mcp) - Official MCP server
- Inspired by [claude-mem](https://github.com/thedotmack/claude-mem)
