# Database MCP Setup Guide

This guide sets up a portable MCP database configuration without hardcoding secrets.

## Recommended Workflow for Windows + Codex (HTTP Local)

Use DBHub HTTP transport as the default path:

- Start DBHub in a separate PowerShell terminal.
- Keep local DBHub endpoint at `http://localhost:5678/mcp`.
- Optionally run production-readonly DBHub at `http://localhost:5679/mcp`.
- Point Codex to the endpoint(s) you run.
- Keep production sources read-only.

Why:

- STDIO startup can fail on Windows/Codex with handshake errors.
- HTTP transport is usually more stable for local MCP sessions.

## 1) Prepare Environment Variables

1. Copy `.env.example` to local `.env` (ignored by git).
2. Optionally create `.env.local` for machine/user overrides.
3. Keep credentials only in local ignored files/environment variables.

## 2) Create Local DBHub Config

```powershell
Copy-Item mcp/database/dbhub.local.example.toml mcp/database/dbhub.local.toml
```

Keep placeholders and local values only. Never commit runtime DBHub config files.

## 3) Start DBHub HTTP Server

The launcher is configurable:

- `-Config` (default: `mcp/database/dbhub.local.toml`)
- `-Port` (default: `5678`)
- `-HostAddress` (default: `localhost`, used for endpoint guidance messages)
- `-Profile` (optional label for safe logs)

The script loads `.env` first and `.env.local` second (`.env.local` overrides `.env`).
The script validates only environment variables referenced by `${VAR_NAME}` placeholders in the selected TOML.

### Workflow A: Single local DBHub

From project root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/start-dbhub-http.ps1
```

Equivalent explicit form:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/start-dbhub-http.ps1 -Config mcp/database/dbhub.local.toml -Port 5678 -Profile dbhub_local
```

### Workflow B: Local + production-readonly DBHub simultaneously

Terminal 1 (local/development):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/start-dbhub-http.ps1 -Config mcp/database/dbhub.local.toml -Port 5678 -Profile dbhub_local
```

Terminal 2 (production-readonly):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/start-dbhub-http.ps1 -Config mcp/database/dbhub.production-readonly.toml -Port 5679 -Profile dbhub_prod
```

Each terminal hosts one DBHub MCP server. Keep both windows open while using MCP clients.

## 4) Configure Codex MCP URL

Project or global Codex config should contain:

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

If the IDE session does not load project MCP config, update global config manually:

```powershell
notepad $env:USERPROFILE\.codex\config.toml
```

Then restart Codex.

## 5) Validate MCP in the Agent

Use the `Universal Database MCP Validation Prompt` in `README.md`.

Validation rules:

- Use `search_objects` first when available.
- Execute only safe `SELECT` queries.
- Do not run writes in production.

## 6) Optional STDIO Fallback

You may use `scripts/start-dbhub.ps1` as fallback when needed.

- HTTP remains the recommended default on Windows + Codex.
- Use STDIO only when your environment/client supports it reliably.

## 7) Restart Requirements

- Restart the relevant DBHub process after changing `.env`, `.env.local`, or the selected TOML.
- Restart Codex after changing MCP server blocks in `.codex/config.toml` or global config.
- If both `dbhub_local` and `dbhub_prod` are configured, verify both appear in `/mcp` after restart.

## 8) Port Conflict Troubleshooting

- Symptom: launcher fails because the selected port is already in use.
- Fix 1: stop the process using that port, then start DBHub again.
- Fix 2: use a different port, for example `-Port 5680`, and update the matching MCP URL in Codex config.
- Fix 3: ensure local and production-readonly instances always use separate ports.
