# Maintaining

## Who can do what
- Users: **Read** role. Owners: Peat, Micah.
- Read-only users can only launch a Codespace if forking is on:
  - Org → Settings → Member privileges → Repository forking → allow forking of private repositories.
  - Repo → Settings → General → Allow forking.
- Codespaces access: Org → Settings → Codespaces → **Selected members**. Set a spending limit.

## Secrets
GitHub Codespaces secrets, scoped to this repo:

| Name | For |
| --- | --- |
| `LINKUP_API_KEY` | Linkup |
| `APIFY_API_KEY` | Apify |
| `NETROWS_API_KEY` | Netrows |

Claude sign-in is not a secret — users sign in once in the terminal: `claude` → Authorize → paste code → Reload Window.

## Add a skill
Create `plugins/stratos-edge/skills/<name>/SKILL.md`. Commit and push. Users get it on rebuild.

## Add a slash command or agent
Add a `.md` file to `plugins/stratos-edge/commands/` or `plugins/stratos-edge/agents/`.

## Add an MCP tool
Add an entry to `mcpServers` in `plugins/stratos-edge/.claude-plugin/plugin.json`, reference its key as `${NAME}`, and add `NAME` as an org Codespaces secret.

## MCP tools
Linkup, Apify, Netrows.
