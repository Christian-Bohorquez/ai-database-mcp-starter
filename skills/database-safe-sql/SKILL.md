# database-safe-sql

## Purpose

Enforce safe, auditable SQL behavior across local and production MCP database workflows.

## Mandatory Behavior

1. Inspect schema first (`search_objects` or equivalent).
2. Verify catalog/reference values with `SELECT` before assuming valid values.
3. Use `SELECT` before any suggested write operation.
4. Use `LIMIT` for exploratory `SELECT` queries.
5. Warn when `WHERE` clauses are broad, missing, or unsafe.
6. Avoid exposing sensitive data in outputs.
7. Ensure DBHub tool-level policy is respected (`readonly`/`max_rows` under `[[tools]]`).

## Environment Policy

### Local/Development

- Reads are allowed.
- Writes may be executed only when the user explicitly authorizes them.

### Production

- Never execute write SQL (`INSERT`, `UPDATE`, `DELETE`, DDL).
- Generate write statements only as manual scripts for human execution.
- After manual execution by the user, generate a `SELECT` query to validate final state.

## Required Workflow for Production Fixes

1. Generate `SELECT` query to validate current state.
2. Generate manual write script suggestion (do not execute).
3. Generate `SELECT` query for post-change validation.

## Review Checklist

- Did we inspect schema first?
- Did we verify catalog values?
- Is there a `SELECT` before write suggestion?
- Is write SQL blocked from execution in production?
- Is there a post-change validation `SELECT`?
- Is `WHERE` precise and safe?
