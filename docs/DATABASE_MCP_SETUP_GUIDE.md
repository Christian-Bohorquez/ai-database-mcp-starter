# Database MCP Setup Guide

This guide sets up a portable MCP database configuration without hardcoding secrets.

## Recommended Workflow for Windows + Codex (HTTP Local)

Use DBHub local HTTP transport as the default path:

- Start DBHub in a separate PowerShell terminal.
- Keep DBHub endpoint at `http://localhost:5678/mcp`.
- Point Codex to that endpoint.
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

From project root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/start-dbhub-http.ps1
```

This script loads `.env` then `.env.local` into process environment before launching DBHub.

## 4) Configure Codex MCP URL

Project or global Codex config should contain:

```toml
[mcp_servers.dbhub]
url = "http://localhost:5678/mcp"
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