# AI Database MCP Starter (Private)

Reusable private starter kit for portable database MCP integration across projects.

## What This Starter Provides

- Codex-first workflow (primary).
- OpenCode-ready example configuration (secondary workflow).
- Claude Desktop MCP example configuration (future client option).
- DBHub as initial MCP database server.
- Templates for PostgreSQL, MySQL, and MariaDB-compatible workflows.
- Safe local-vs-production policy and SQL workflow documentation.

## Safety Model

- Local/development databases:
  - Read queries are allowed.
  - Write operations are allowed only with explicit user authorization.
- Production databases:
  - Read-only usage only (`SELECT`, schema discovery).
  - Agent never executes write SQL in production.
  - Real production database user must also be read-only.

## Human-in-the-Loop SQL Workflow

1. `SELECT` before (validate current state).
2. Suggested manual `UPDATE`/`INSERT`/`DELETE` script (human executes outside MCP).
3. `SELECT` after (validate final state).

## Included Structure

- `.codex/config.toml.example`
- `mcp/database/*` templates
- `agents/*` role definitions
- `skills/database-safe-sql/SKILL.md`
- `docs/*` policy and workflow guides
- `.env.example`
- `templates/` examples for OpenCode and Claude Desktop
- `scripts/install-kit.ps1` installer

## Quick Use

1. Copy this starter into a target project.
2. Add required ignore rules from `.gitignore` or `templates/gitignore-snippet.txt`.
3. Copy examples into local runtime files:
   - `.codex/config.toml.example` -> `.codex/config.toml`
   - `mcp/database/dbhub.local.example.toml` -> `mcp/database/dbhub.local.toml`
4. Fill credentials only through environment variables/local ignored files.
5. Keep production integration read-only.

## Never Commit

- `.env`
- `.env.local`
- `.codex/config.toml`
- `mcp/database/dbhub.local.toml`
- `mcp/database/dbhub.production-readonly.toml`
- `mcp/database/*.secret.toml`
