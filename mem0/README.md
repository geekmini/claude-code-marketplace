# Mem0 Plugin for Claude Code

Global memory layer for Claude Code using self-hosted Mem0 service. Automatically stores and retrieves contextual memories across sessions.

## Features

- **Automatic Memory Retrieval**: When you ask a question, Claude automatically searches for relevant memories
- **Automatic Memory Storage**: Important information from conversations is automatically saved
- **Semantic Search**: Finds related memories even with different wording
- **Zero Configuration**: Works transparently without manual commands

## Prerequisites

- Self-hosted Mem0 service with MCP endpoint
- MCP endpoint: `https://mem0-mcp.tron.home/sse`

## Installation

### Option 1: Plugin Directory

```bash
claude --plugin-dir /path/to/claude-plugins/mem0
```

### Option 2: Add to Settings

Add to `~/.claude/settings.json`:

```json
{
  "pluginDirs": ["/path/to/claude-plugins/mem0"]
}
```

## How It Works

### Memory Retrieval (UserPromptSubmit Hook)

When you send a message, the plugin:
1. Analyzes your prompt
2. Searches Mem0 for relevant memories
3. Injects matching memories into context

**Example:**
```
You: "What's the IP of my k3s server?"
[Hook finds: "k3s-server IP is 192.168.31.246"]
Claude: "Your k3s-server IP is 192.168.31.246"
```

### Memory Storage (Stop Hook)

When a conversation ends, the plugin:
1. Analyzes the conversation
2. Extracts important facts and preferences
3. Saves them to Mem0

**What gets saved:**
- User preferences
- Project configurations
- Technical decisions
- Environment details

**What doesn't get saved:**
- Generic code examples
- Temporary debugging steps
- Trivial exchanges

## MCP Tools Available

| Tool | Description |
|------|-------------|
| `add_memory` | Store a new memory |
| `search_memory` | Search memories semantically |
| `get_memories` | List all memories |
| `delete_memory` | Remove a memory |

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Claude Code                        │
├─────────────────────────────────────────────────────┤
│  UserPromptSubmit Hook    │    Stop Hook            │
│  (auto search memories)   │    (auto save memories) │
├─────────────────────────────────────────────────────┤
│                    MCP (SSE)                         │
├─────────────────────────────────────────────────────┤
│              mem0-mcp.tron.home                      │
│              (MCP Sidecar)                           │
├─────────────────────────────────────────────────────┤
│              memory.tron.home                        │
│              (Mem0 REST API)                         │
├─────────────────────────────────────────────────────┤
│              PostgreSQL + pgvector                   │
│              (Vector Storage)                        │
└─────────────────────────────────────────────────────┘
```

## Troubleshooting

### Check MCP Connection

```bash
curl -sk https://mem0-mcp.tron.home/health
```

### View Loaded Hooks

In Claude Code, run `/hooks` to see active hooks.

### Debug Mode

```bash
claude --debug
```

## License

MIT
