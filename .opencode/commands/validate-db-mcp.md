# OpenCode Command: Validate DB MCP

Use the `dbhub` MCP server (for example `dbhub_local`, and optional read-only `dbhub_prod`) to run the Universal Database MCP Validation Prompt from `README.md`.

Requirements:

- DBHub HTTP must already be running.
- Follow read-only safety during validation.
- Do not run production write SQL.
- Do not print secrets.

Procedure:

1. Load the Universal Database MCP Validation Prompt from `README.md`.
2. Execute validation against the selected dbhub MCP server.
3. Report tools found, schema discovery result, engine/context result, and safety compliance.