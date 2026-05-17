# database-safe-sql (OpenCode Adapter)

## Purpose

OpenCode adapter for the portable database safe SQL policy.

## Required Behavior

1. Ensure DBHub HTTP is running first.
2. Use `search_objects` before query generation when available.
3. Use `SELECT` before any suggested write statement.
4. Production MCP is read-only only.
5. For production corrections, generate manual write scripts only, never execute them.
6. Generate a post-change validation `SELECT` query.
7. Never expose secrets.

## References

- `docs/AI_DATABASE_MCP_POLICY.md`
- `docs/DATABASE_SAFE_SQL_WORKFLOW.md`
- Universal Database MCP Validation Prompt in `README.md`