# Database Safe SQL Workflow

This workflow applies to all MCP-driven SQL operations, with strict production safeguards.

## Core Rules

- When multiple MCP servers are available, explicitly state the selected source/server before generating SQL (for example `dbhub_local` or `dbhub_prod`).
- Inspect schema first.
- Verify catalog/reference values with `SELECT` before assuming them.
- Use `LIMIT` for exploratory reads.
- In production, do not execute write SQL through the agent.
- In production, the agent may generate manual write scripts only; execution must be performed by a human outside MCP.
- In production DBHub templates, `execute_sql` must be configured with `readonly = true`.

## Readonly Validation Snapshot

A successful starter workflow validation should confirm:

- MCP loads with `execute_sql` and `search_objects` available.
- Database context queries and metadata queries run using `SELECT` only.
- No write SQL is attempted.
- Readonly mode stays enabled for production profiles.

Use the `Universal Database MCP Validation Prompt` from `README.md` for repeatable checks.

## Production Correction Pattern

### 1) SELECT before (validate current state)

```sql
SELECT
  payment_id,
  customer_id,
  payment_method,
  bank_code,
  updated_at
FROM payments
WHERE payment_id = 102938
LIMIT 1;
```

### 2) Suggested UPDATE (manual execution only)

The agent may provide:

```sql
UPDATE payments
SET
  payment_method = 'BANK_TRANSFER',
  bank_code = 'PICHINCHA',
  updated_at = NOW()
WHERE payment_id = 102938;
```

In production, this statement is a script suggestion only. A human must execute it manually outside MCP.

### 3) SELECT after (verify result)

```sql
SELECT
  payment_id,
  payment_method,
  bank_code,
  updated_at
FROM payments
WHERE payment_id = 102938
LIMIT 1;
```

## Unsafe Pattern Warnings

Agent/reviewer must flag queries when:

- `WHERE` is missing in write SQL.
- `WHERE` is too broad and may affect multiple records unintentionally.
- Catalog values are assumed without validation.

## Minimal Validation Expansion

When needed, add quick catalog verification first:

```sql
SELECT DISTINCT payment_method
FROM payments
ORDER BY payment_method
LIMIT 50;
```
