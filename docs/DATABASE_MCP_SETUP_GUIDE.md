# Database MCP Setup Guide

This guide sets up a portable, project-local MCP database configuration without hardcoding secrets.

## 1) Prepare Environment Variables

1. Copy `.env.example` to a local `.env` (ignored by git).
2. Fill only local values first (PostgreSQL recommended for initial validation).
3. Keep production values only in local secret storage.

## 2) Create Local DBHub Config

Copy template:

```powershell
Copy-Item mcp/database/dbhub.local.example.toml mcp/database/dbhub.local.toml
```

Use environment placeholders; do not paste raw credentials into committed files.
The DBHub templates in this repository follow official TOML sections:

- `[[sources]]` for source definitions
- `[[tools]]` for tool settings/exposure (`name`, `source`, `readonly`, `max_rows`)

## 3) Create Local Codex MCP Config

Copy template:

```powershell
Copy-Item .codex/config.toml.example .codex/config.toml
```

Expected DBHub launch pattern:

- `npx`
- `@bytebase/dbhub@latest`
- `--transport stdio`
- `--config mcp/database/dbhub.local.toml`

## 4) First Test Strategy (Local PostgreSQL)

Recommended sequence:

1. Start with schema discovery using `search_objects`.
2. Run constrained `SELECT ... LIMIT ...` queries.
3. Only execute local writes after explicit user authorization.

Do not test against production first.

## 5) Adapt Later to MySQL/MariaDB

- Reuse the same policy and workflow.
- Add/adjust source entries in DBHub config for MySQL/MariaDB.
- Keep source IDs stable (`local_mysql`, `production_mysql_readonly`) to reduce prompt/tool drift.
- For MariaDB, use MySQL-compatible configuration unless a dedicated engine type is required by your DBHub version.
- Keep production tool settings as `readonly = true`, `max_rows = 100`, and source `lazy = true`.

## 6) Add OpenCode Later Without Changing MCP Logic

To support OpenCode as a secondary client:

- Keep the same DBHub config files and source IDs.
- Keep the same environment-variable contract.
- Keep the same safe SQL policy documents and workflow.

The MCP backend logic stays unchanged; only the client/orchestrator changes.
