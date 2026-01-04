---
description: Synchronize CLAUDE.md with current project state
argument-hint: [--force]
allowed-tools: Read, Write, Glob, Grep, Bash, AskUserQuestion
---

Synchronize CLAUDE.md with the current project state.

## Workflow

1. **Detect Project Type**
   - Scan root directory for indicator files
   - Identify: Infrastructure (K8s, Helm, ArgoCD), Code (Node, Python, Go, Java), or Monorepo
   - Note secondary characteristics (CI/CD, containerization, testing)

2. **Analyze Current State**
   Use appropriate analysis based on detected type:
   - Infrastructure: List namespaces, services, deployments, storage
   - Code: List dependencies, scripts, entry points, tests
   - Monorepo: List packages, internal dependencies

3. **Read Existing CLAUDE.md**
   - If exists: Parse sections, identify documented items
   - If missing: Note that new file will be created

4. **Compare and Generate Diff**
   - Identify outdated items (removed, renamed)
   - Identify missing items (new services, dependencies)
   - Identify changed items (updated versions, URLs)

5. **Present Changes**
   Show unified diff format:
   ```diff
   - Removed item
   + Added item
   ```

6. **Confirm and Apply**
   - Use AskUserQuestion to confirm changes
   - If confirmed: Apply updates preserving custom sections
   - If declined: Report what was not changed

## Arguments

- `--force`: Skip confirmation, apply all detected changes

## Output

Provide a sync report including:
- Project type detected
- Changes found (added, removed, modified)
- Sections updated
- Final status

## Quality Rules

- Preserve custom user sections (anything not auto-detected)
- Maintain existing formatting style
- Keep Quick Reference section concise
- Use tables for structured data
- Add section separators (---) between major sections
