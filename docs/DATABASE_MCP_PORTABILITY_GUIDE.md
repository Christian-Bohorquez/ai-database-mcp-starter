# Database MCP Portability Guide

This guide explains how to reuse this MCP database structure across projects, engines, and agent clients.

## Portable Design Principles

- Keep MCP configuration project-local.
- Keep credentials external (env vars, ignored local files).
- Keep policy documents reusable and engine-agnostic.
- Separate local write-capable configs from production read-only configs.
- Keep official DBHub TOML structure (`[[sources]]` and `[[tools]]`) unchanged across projects.

## Reuse in PostgreSQL Projects

- Use `local_postgres` as primary development source.
- Keep the same safe SQL workflow and read-before-write discipline.

## Reuse in MySQL/MariaDB Projects

- Use `local_mysql` and/or `local_mariadb` for development.
- Use `production_mysql_readonly` for production inspection.
- Keep production read-only enforcement in both DBHub tool config and DB permissions.

## Client Portability

- Codex is the primary workflow for this starter.
- OpenCode is optional/future and can reuse the same DBHub HTTP endpoint once configured.
- Claude Desktop is a future client option and should be verified before production use.

## Final Recommendation

- Codex + Windows: prefer local HTTP DBHub launcher (`scripts/start-dbhub-http.ps1`) and endpoint `http://localhost:5678/mcp`.
- OpenCode: can reuse the same endpoint or equivalent local MCP wiring later.
- Claude Desktop: may point to the same DBHub server once compatibility is verified.

## Governance Consistency

Across clients, keep these constants:

- Same source IDs and naming conventions.
- Same `readonly` production constraints.
- Same manual write workflow for production corrections.
- Same validation baseline via the Universal Database MCP Validation Prompt.