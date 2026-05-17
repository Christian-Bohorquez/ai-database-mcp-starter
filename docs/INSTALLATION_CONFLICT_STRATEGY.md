# Installation Conflict Strategy

This guide explains how to install the starter safely when the target project already has existing folders.

## Existing Folder Scenarios

If the target already has any of these folders, do not assume replacement is safe:

- `agents/`
- `docs/`
- `.opencode/`
- `scripts/`

Windows folder copy behavior usually merges directories, but same-path files can be overwritten when forced.

## Starter Installer Default

- `scripts/install-kit.ps1` skips existing files by default.
- Use `-Force` only when you intentionally want replacement.
- Use `-DryRun` to preview planned copies and skips before changing files.

## Namespaced Paths to Reduce Collisions

Use these namespaced paths for database MCP assets:

- `agents/database-mcp/`
- `skills/database-safe-sql/`
- `.opencode/agents/database-safe-sql-reviewer.md`
- `.opencode/skills/database-safe-sql/`

## Conflict-Safe Merge Guidance

1. Run installer without `-Force` first.
2. Review skipped files.
3. Manually compare conflicting files before replacement.
4. Re-run with `-Force` only for files you explicitly want to replace.

## Avoid Destructive Copy Modes

- Do not use destructive sync/mirror modes that delete target files.
- Do not use blanket overwrite commands for entire folders.
- Keep project-specific customizations intact unless intentionally refactored.