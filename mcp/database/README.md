# MCP Database Integration (Portable)

This folder contains project-local MCP database configuration templates for agentic workflows.

## Purpose

- Keep database MCP setup close to the repository.
- Provide a portable pattern reusable across projects.
- Separate local write-capable examples from production read-only examples.

## Recommended Windows + Codex Flow (HTTP Local)

1. Create local `.env` and/or `.env.local` (ignored by git).
2. Copy `mcp/database/dbhub.local.example.toml` to `mcp/database/dbhub.local.toml`.
3. Start DBHub HTTP from project root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/start-dbhub-http.ps1
```

4. Configure Codex MCP URL to `http://localhost:5678/mcp` (project or global config).
5. Validate with the Universal Database MCP Validation Prompt from `README.md`.

## Why HTTP is Preferred on Windows + Codex

- STDIO startup can fail on some Windows/Codex setups due to handshake timing.
- Local HTTP endpoint keeps MCP transport stable and easy to verify.

## Local vs Production Profiles

- Local/development profiles may use `readonly = false` only after explicit user authorization.
- Production profiles must enforce `readonly = true`.
- Production usage is schema inspection + `SELECT` only.
- Production sources should remain `lazy = true`.

## DBHub TOML Shape Used Here

- `[[sources]]` defines connection sources using DSNs with `${VAR_NAME}` placeholders.
- `[[tools]]` defines tool exposure and behavior:
  - `name = "execute_sql"` with `readonly` and `max_rows`
  - `name = "search_objects"` for schema/object discovery

## Files

- `dbhub.local.example.toml`: local PostgreSQL/MySQL/MariaDB-compatible example.
- `dbhub.production-readonly.example.toml`: production read-only example.
- `dbhub.multi-environment.example.toml`: combined multi-source example.

## Never Commit

- `.env`
- `.env.local`
- `.codex/config.toml`
- `mcp/database/dbhub.local.toml`
- `mcp/database/dbhub.production-readonly.toml`
- `mcp/database/*.secret.toml`

Never commit real credentials, tokens, or production hosts.