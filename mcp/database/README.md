# MCP Database Integration (Portable)

This folder contains project-local MCP database configuration templates for agentic workflows.

## Purpose

- Keep database MCP setup close to the repository.
- Provide a portable pattern that can be reused in other projects.
- Separate local write-capable examples from production read-only examples.

## Why DBHub as initial MCP server

- It provides an MCP-compatible interface for database inspection and SQL execution.
- It supports practical multi-source configuration for PostgreSQL and MySQL-style engines.
- It works with a Codex-first workflow today and can be reused by other MCP-capable clients later.
- It supports official TOML sections `[[sources]]` and `[[tools]]` with per-tool controls like `readonly` and `max_rows`.

## Portability Across Projects

You can copy this entire `mcp/database/` folder to any new repository and only change:

1. Environment variable names (if needed).
2. Source IDs.
3. Engine-specific connection details.
4. Row limits and tool policies according to project risk.

The policy and workflow documents under `docs/` remain reusable with minimal edits.

## Local vs Production Profiles

- Local/development profiles may allow `execute_sql` with `readonly = false` only when the user explicitly authorizes writes.
- Production profiles must enforce read-only behavior with `readonly = true`.
- Production usage is limited to schema inspection and `SELECT` queries.
- Production templates also use `lazy = true` to avoid unnecessary startup connection attempts.

## DBHub TOML Shape Used Here

- `[[sources]]` defines connection sources, using DSN strings with `${VAR_NAME}` placeholders.
- `[[tools]]` defines tool exposure and tool-level settings:
  - `name = "execute_sql"` with `readonly` and `max_rows`
  - `name = "search_objects"` for explicit schema-discovery tool exposure
- `readonly` and `max_rows` are intentionally kept at tool level, not source level.

`search_objects` is built-in and enabled by default in DBHub, but these templates configure it explicitly so exposed tools remain deterministic across different MCP clients.

## Why production must be read-only

- Protects critical data from accidental mutation by automated agents.
- Keeps human approval mandatory for all production write operations.
- Supports auditable, safer remediation flow (SELECT before -> manual script -> SELECT after).

## File Usage

- `dbhub.local.example.toml`: local PostgreSQL/MySQL/MariaDB-compatible example.
- `dbhub.production-readonly.example.toml`: production read-only example.
- `dbhub.multi-environment.example.toml`: combined multi-source example.

## Copy Workflow

Create local runtime files from templates:

```powershell
Copy-Item mcp/database/dbhub.local.example.toml mcp/database/dbhub.local.toml
Copy-Item mcp/database/dbhub.production-readonly.example.toml mcp/database/dbhub.production-readonly.toml
Copy-Item .codex/config.toml.example .codex/config.toml
```

Then update values through environment variables and local ignored files only.

## Never Commit

- `.env`
- `.env.local`
- `.codex/config.toml`
- `mcp/database/dbhub.local.toml`
- `mcp/database/dbhub.production-readonly.toml`
- `mcp/database/*.secret.toml`

Never commit real credentials, real production hosts, tokens, or passwords.
