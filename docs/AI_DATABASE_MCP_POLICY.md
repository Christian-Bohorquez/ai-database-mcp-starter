# AI Database MCP Policy

## Scope

This policy governs how agents use MCP database tools in this project.

## Environment Rules

### Local/Development

- MCP may read and write only with explicit user authorization.
- Default agent behavior should still begin with read/inspection queries.

### Production

- MCP is observation-only.
- MCP may inspect schema and run `SELECT` queries only.
- MCP must never execute `INSERT`, `UPDATE`, `DELETE`, DDL, or administrative statements.
- DBHub config must enforce `readonly = true` in `[[tools]]` for production sources.
- Production sources should use `lazy = true` to avoid unnecessary startup connections.

## Human-in-the-loop Requirement

For production data corrections:

1. Agent generates a `SELECT` query to verify current state.
2. Agent generates write SQL only as a manual script suggestion.
3. User executes the script manually outside the agent.
4. Agent generates a `SELECT` validation query for post-change verification.

## Credential and Account Policy

- Never use admin/root/postgres superuser credentials for MCP agent access.
- Use separate least-privilege database users:
  - `mcp_local_rw`
  - `mcp_local_ro`
  - `mcp_prod_ro`
- The production account must be read-only at the database permission level.

## Data Handling and Safety

- Never assume catalog/domain values; verify with `SELECT`.
- Use `LIMIT` in exploratory queries.
- Avoid broad/unsafe `WHERE` clauses in suggested writes.
- Avoid exposing sensitive data in query results or logs.

## Secret Storage

- Store credentials only in environment variables or local ignored files.
- Never commit credentials, tokens, real hosts, or passwords to the repository.
