# AGENTS.md

## Scope

This repository standardizes database MCP workflows for safe reuse across projects.

## Platform Priority

- DBHub is the database MCP server used by this starter.
- Codex is the primary workflow.
- OpenCode is the secondary/additional workflow.
- Claude Desktop and Claude Skills are future integrations and must be validated before use.

## Mandatory Safety Policy

- Production databases are read-only only.
- Local databases may be read/write only after explicit user authorization.
- Follow `docs/AI_DATABASE_MCP_POLICY.md`.
- Follow `docs/DATABASE_SAFE_SQL_WORKFLOW.md` before generating SQL.
- For SQL corrections use this sequence:
  1. `SELECT` before
  2. Suggested manual write SQL
  3. `SELECT` after
- Production write SQL must never be executed by the agent.
- Never expose secrets.
- Never commit `.env`, `.env.local`, `.codex/config.toml`, `mcp/database/dbhub.local.toml`, or production runtime configs.

## Validation Requirement

Use the Universal Database MCP Validation Prompt from `README.md` before database-related work.

## Tool-Specific Usage

- Codex: use `.codex` MCP configuration examples and this `AGENTS.md` as baseline behavior.
- OpenCode: use `.opencode/agents`, `.opencode/skills`, and `.opencode/commands` in addition to this baseline.
- Claude (future): use `templates/claude-*` examples and verify compatibility before use.