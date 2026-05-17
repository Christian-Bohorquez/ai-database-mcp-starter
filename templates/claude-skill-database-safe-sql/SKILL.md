# Claude Skill: Database Safe SQL (Future)

Status: Future / verify-before-use.

This template is not tested in this starter repository.

## Preconditions

- Verify your Claude Desktop/Claude Skills environment supports your chosen MCP integration mode.
- Validate DBHub HTTP connectivity (`http://localhost:5678/mcp` local, optional `http://localhost:5679/mcp` production-readonly) or equivalent Claude-compatible MCP configuration before use.

## Safety Policy

- Follow `docs/AI_DATABASE_MCP_POLICY.md`.
- Follow `docs/DATABASE_SAFE_SQL_WORKFLOW.md`.
- Production is read-only only.
- Never execute production write SQL through the agent.
- Production correction flow:
  1. `SELECT` before
  2. Suggested manual write SQL
  3. `SELECT` after
- Never expose secrets.