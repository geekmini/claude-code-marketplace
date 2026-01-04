# claude-md-sync

Automatically keeps CLAUDE.md synchronized with project state.

## Features

- **Auto-detection**: Identifies project type (K8s/Infra, Node.js, Python, Go, Java, Monorepo)
- **Smart analysis**: Analyzes codebase structure, dependencies, and patterns
- **Diff-based updates**: Shows proposed changes before applying
- **Project-specific templates**: Tailored CLAUDE.md sections per project type

## Components

| Component | Description |
|-----------|-------------|
| `project-analysis` skill | Detects project type from files and structure |
| `claude-md-authoring` skill | Templates and best practices for CLAUDE.md |
| `claude-md-updater` agent | Proactively suggests and applies updates |
| `/sync-claude-md` command | Manual trigger for sync workflow |

## Usage

### Automatic (Recommended)

The `claude-md-updater` agent activates proactively when:
- Starting a session in a project with CLAUDE.md
- After significant codebase changes
- When discussing project documentation

### Manual

```
/sync-claude-md
```

Forces a full analysis and update proposal.

## Supported Project Types

- **Infrastructure**: Kubernetes, ArgoCD, Helm, Terraform
- **Node.js**: npm/yarn/pnpm projects
- **Python**: pip, poetry, pipenv projects
- **Go**: Go modules
- **Java**: Maven, Gradle projects
- **Monorepo**: Nx, Turborepo, Lerna

## Installation

From the GeekMini Claude Plugins marketplace:

```bash
# Clone the repository
git clone https://github.com/geekmini/claude-plugins.git

# Install the plugin
claude mcp add-json claude-md-sync '{"type":"prompt","path":"path/to/claude-plugins/claude-md-sync/.claude-plugin"}'
```

Or add to your Claude Code settings:
```json
{
  "plugins": ["path/to/claude-plugins/claude-md-sync"]
}
```
