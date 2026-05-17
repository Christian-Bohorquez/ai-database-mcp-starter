# AI Database MCP Policy

## Scope

This policy governs how agents use MCP database tools in this project.

## Environment Rules

### Local/Development

- MCP may read and write only with explicit user authorization.
- Default behavior starts with schema discovery and safe `SELECT` queries.
- For Windows + Codex, prefer DBHub HTTP local transport.
- Multiple MCP database servers may run simultaneously only with clear names and separate ports.

### Production

- MCP is observation-only.
- MCP may inspect schema and run `SELECT` queries only.
- MCP must never execute `INSERT`, `UPDATE`, `DELETE`, DDL, or administrative statements.
- Production MCP server names must include `prod` or `production` (for example `dbhub_prod`).
- DBHub config must enforce `readonly = true` in `[[tools]]` for production sources.
- Production database users must also be read-only at the database permission level.
- Production sources should use `lazy = true` to avoid unnecessary startup connections.
- Never mix production read-write access into MCP.

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

## Validation Standard

- Use the `Universal Database MCP Validation Prompt` in `README.md` to validate MCP availability and safe SQL behavior.
- Validation must avoid row-level sensitive data and avoid `SELECT *` on large/sensitive tables.

## Secret Storage

- Store credentials only in environment variables or local ignored files.
- Never commit credentials, tokens, real hosts, or passwords.
