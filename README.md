# AI Database MCP Starter Kit

## Purpose

This repository is a reusable private starter kit for connecting AI development tools to databases through MCP, using DBHub as the initial database MCP server.

Supported usage:

- Codex primary workflow.
- OpenCode optional/future workflow.
- Claude Desktop possible future client.
- PostgreSQL local/development.
- MySQL/MariaDB local/development.
- MySQL/MariaDB production read-only.

## Universal Database MCP Validation Prompt

Use this prompt in Codex, OpenCode, Claude, or another MCP-capable client:

```text
Validate database MCP connectivity in read-only mode.

Safety rules:
- Do not print secrets.
- Do not print .env or .env.local contents.
- Do not run INSERT, UPDATE, DELETE, ALTER, DROP, CREATE, TRUNCATE, GRANT, or REVOKE.
- Run SELECT queries only.
- Do not use SELECT * on large or sensitive tables.
- Do not query row-level sensitive data.
- Keep readonly mode unchanged.

Tasks:
1. Confirm the database MCP server is loaded.
2. List available MCP tools.
3. If search_objects is available, run schema/object discovery first.
4. Detect the configured source/engine and choose the correct query set:

PostgreSQL validation queries:
SELECT current_database();
SELECT current_schema();
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name
LIMIT 30;

MySQL/MariaDB validation queries:
SELECT DATABASE();
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema NOT IN ('information_schema', 'mysql', 'performance_schema', 'sys')
ORDER BY table_schema, table_name
LIMIT 30;

5. If tables are found, choose one non-sensitive table and inspect columns only:
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = '<schema>'
  AND table_name = '<table>'
ORDER BY ordinal_position;

Final report must include:
- MCP loaded successfully or not
- available tools
- database engine if known
- current database/schema
- sample discovered tables
- sample columns
- readonly status
- whether any write SQL was attempted
- errors
```

## DBHub

DBHub is the database MCP server used by this starter. It gives Codex/OpenCode/Claude a controlled way to inspect schemas and execute safe read-only SQL.

Recommended workflow for Windows + Codex is local HTTP transport with explicit config and port parameters.

Start DBHub from project root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/start-dbhub-http.ps1
```

Operational notes:

- Run from the project root.
- Do not close that PowerShell window while using MCP.
- Expected endpoint: `http://localhost:5678/mcp`.
- That terminal must stay open because it hosts the running DBHub MCP server.

## Running Multiple DBHub MCP Servers

You can run local and production-readonly DBHub instances at the same time.

- Use different ports per instance.
- Use clear names such as `dbhub_local` and `dbhub_prod`.
- Local may be read/write only when explicitly authorized and configured.
- Production must always be read-only.

Example commands from project root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/start-dbhub-http.ps1 -Config mcp/database/dbhub.local.toml -Port 5678
```

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/start-dbhub-http.ps1 -Config mcp/database/dbhub.production-readonly.toml -Port 5679
```

Operational notes:

- Do not close the PowerShell windows.
- Each running terminal is one DBHub MCP server.
- Codex connects to each server through its own URL.

## Codex

Codex must point to the DBHub HTTP endpoints you run.

In some cases, project-local `.codex/config.toml` is not enough. If Codex IDE does not load project MCP settings, update global Codex config manually:

```powershell
notepad $env:USERPROFILE\.codex\config.toml
```

Use this MCP block:

```toml
[mcp_servers.dbhub_local]
url = "http://localhost:5678/mcp"
startup_timeout_sec = 30
tool_timeout_sec = 60
enabled = true
enabled_tools = ["execute_sql", "search_objects"]

[mcp_servers.dbhub_prod]
url = "http://localhost:5679/mcp"
startup_timeout_sec = 30
tool_timeout_sec = 60
enabled = true
enabled_tools = ["execute_sql", "search_objects"]
```

Checklist:

- Keep DBHub HTTP instances running before opening/restarting Codex.
- Restart Codex after config changes.
- Run `/mcp` in Codex and verify `dbhub_local` and/or `dbhub_prod` appear.
- If an expected server appears, run the Universal Database MCP Validation Prompt.
- If a server does not appear, verify:
  - Its DBHub terminal is still running.
  - Endpoint matches the configured URL, such as `http://localhost:5678/mcp` or `http://localhost:5679/mcp`.
  - Global Codex config includes the same MCP server block.
  - Project is trusted.
  - Codex was restarted after config changes.

## Troubleshooting

- `codex is not recognized`:
  - Codex CLI is not installed in PATH. Use Codex IDE settings/global config manually.
- `/mcp does not show dbhub`:
  - Codex has not loaded MCP. Check global config and restart Codex.
- `timed out handshaking with MCP server`:
  - STDIO startup may be failing. Prefer HTTP local transport on Windows.
- `connection closed: initialize response`:
  - STDIO handshake failed. Prefer HTTP local transport.
- `getaddrinfo ENOTFOUND ${LOCAL_POSTGRES_HOST}`:
  - Environment variables were not expanded. Use `scripts/start-dbhub-http.ps1` so `.env` and `.env.local` are loaded into process environment.
- `better-sqlite3 binding error in demo mode`:
  - DBHub demo mode uses SQLite and can fail on some Windows/Node versions. This does not necessarily affect PostgreSQL/MySQL/MariaDB validation.
- `DBHub server terminal closed`:
  - Restart `scripts/start-dbhub-http.ps1` before using Codex.

## OpenCode

OpenCode setup is optional/future in this starter.

- The same DBHub HTTP endpoint can likely be reused once OpenCode MCP client configuration is in place.
- This flow has not been validated in this repository environment yet.
- DBHub HTTP must be running first.
- See `templates/opencode.json.example` for a conservative example configuration.

## Security Rules

- Never commit `.env`, `.env.local`, `.codex/config.toml`, `mcp/database/dbhub.local.toml`, or production runtime configs.
- Never use root/admin/postgres production credentials.
- Use separate users:
  - `mcp_local_rw`
  - `mcp_local_ro`
  - `mcp_prod_ro`
- Production is read-only only.
- Production workflow:
  1. SELECT before
  2. suggested manual UPDATE/INSERT/DELETE
  3. SELECT after
- Agent never executes production writes.
