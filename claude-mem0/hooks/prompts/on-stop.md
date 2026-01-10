# Memory Capture - Task Completion

Before completing this task, evaluate if there are valuable learnings worth remembering for future sessions.

## What to Capture

**Global memories** (use user_id only):
- User preferences discovered (coding style, formatting, tools)
- Personal information shared (name, role, expertise)
- Workflow preferences (commit style, review process)
- Technology preferences (frameworks, libraries, patterns)

**Project memories** (use user_id + app_id):
- Architecture decisions made
- Codebase patterns discovered
- Bug fixes and their root causes
- Configuration or setup details
- Important file locations and their purposes

## How to Capture

Use the `add_memory` tool with appropriate scoping:
- For global: `user_id` only
- For project: `user_id` and `app_id` (project identifier)

## Decision Criteria

Only capture if the learning is:
- **Reusable**: Will be valuable in future sessions
- **Non-obvious**: Not something easily rediscovered
- **Stable**: Unlikely to change frequently

Skip capture if:
- Task was trivial (simple question, small fix)
- No new information was learned
- Information is already in codebase (README, comments)

## Action

If there are memories worth saving, use `add_memory` now. Otherwise, approve stopping.

Return `approve` to stop or `block` if you need to save memories first.
