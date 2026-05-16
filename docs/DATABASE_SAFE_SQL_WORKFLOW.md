# Database Safe SQL Workflow

This workflow applies to all MCP-driven SQL operations, with strict production safeguards.

## Core Rules

- Inspect schema first.
- Verify catalog/reference values with `SELECT` before assuming them.
- Use `LIMIT` for exploratory reads.
- In production, do not execute write SQL through the agent.
- In production DBHub templates, `execute_sql` must be configured with `readonly = true`.

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
