# Database MCP Portability Guide

This guide explains how to reuse this MCP database structure across projects, engines, and agent clients.

## Portable Design Principles

- Keep MCP configuration project-local.
- Keep credentials external (env vars, ignored local files).
- Keep policy documents reusable and engine-agnostic.
- Separate local write-capable configs from production read-only configs.
- Keep official DBHub TOML structure (`[[sources]]` and `[[tools]]`) unchanged across projects.

## Reuse in Thesis Dashboard Projects (PostgreSQL)

- Use `local_postgres` source as primary development source.
- Keep the same safe SQL workflow and read-before-write discipline.
- Add project-specific schema exploration prompts, not project-specific security exceptions.

## Reuse in Business Systems (MySQL/MariaDB)

- Use `local_mysql` for development and `production_mysql_readonly` for production inspection.
- Treat MariaDB as MySQL-compatible unless your DBHub version requires another type.
- Keep production read-only enforcement in both tool config and DB permissions.

## Reuse in Any Language or Framework

This structure is independent from backend/frontend stacks because it isolates:

- MCP server wiring (`.codex/config.toml` pattern)
- DB source definitions (`mcp/database/*.toml`)
- Tool restrictions and exposure (`readonly`, `max_rows`, explicit `search_objects`)
- Operational policy (`docs/*.md`)
- Agent behavior contracts (`agents/*.md`, `skills/database-safe-sql/SKILL.md`)

Whether the app is FastAPI, Spring, Laravel, Node, or .NET, the MCP layer remains valid.

## Codex-first Workflow

- Codex uses project-local MCP config examples.
- Agent roles and skill prompts enforce safe SQL handling.
- Production updates remain human-approved and manually executed.

## OpenCode as Secondary Tool

- OpenCode can consume the same DBHub configuration model and policy files.
- Keep IDs, variable names, and workflow wording stable to avoid behavioral divergence.
- No MCP logic rewrite is required; only client integration changes.

## Claude Desktop as Future Client

- If Claude Desktop is added later, keep DBHub as shared MCP server baseline.
- Reuse the same source IDs and safety rules.
- Preserve the same production manual-write process to keep governance consistent across clients.
