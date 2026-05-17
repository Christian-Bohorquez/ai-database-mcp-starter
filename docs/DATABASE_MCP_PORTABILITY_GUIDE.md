# Database MCP Portability Guide

This guide explains how to reuse this MCP database structure across projects, engines, and agent clients.

## Portable Design Principles

- Keep MCP configuration project-local.
- Keep credentials external (env vars, ignored local files).
- Keep policy documents reusable and engine-agnostic.
- Separate local write-capable configs from production read-only configs.
- Keep official DBHub TOML structure (`[[sources]]` and `[[tools]]`) unchanged across projects.

## Reuse in PostgreSQL Projects

- Use PostgreSQL local/development on port `5678` (or another selected port).
- Keep the same safe SQL workflow and read-before-write discipline.

## Reuse in MySQL/MariaDB Projects

- Use MySQL/MariaDB local/development on port `5678` or another selected port.
- Use production-readonly on a separate port (for example `5679`) for production inspection.
- Keep production read-only enforcement in both DBHub tool config and DB permissions.

## Multi-Instance Pattern

The same starter can run multiple DBHub HTTP instances at once by changing only `-Config` and `-Port`:

- local PostgreSQL on `5678`
- local MySQL/MariaDB on `5678` or another local port
- production-readonly on `5679`

This pattern is reusable in future projects by updating:

- environment values in `.env` and `.env.local`
- DBHub TOML files under `mcp/database`
- startup command parameters (`-Config`, `-Port`, optional `-Profile`)

## Client Portability

- Codex is the primary workflow for this starter.
- OpenCode is optional/future and can reuse the same DBHub HTTP endpoint once configured.
- Claude Desktop is a future client option and should be verified before production use.

## Final Recommendation

- Codex + Windows: prefer local HTTP DBHub launcher (`scripts/start-dbhub-http.ps1`) and explicit ports per instance.
- OpenCode: can reuse the same endpoint or equivalent local MCP wiring later.
- Claude Desktop: may point to the same DBHub server once compatibility is verified.

## Governance Consistency

Across clients, keep these constants:

- Same source IDs and naming conventions.
- Same `readonly` production constraints.
- Same manual write workflow for production corrections.
- Same validation baseline via the Universal Database MCP Validation Prompt.
