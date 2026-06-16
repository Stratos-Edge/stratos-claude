# Maintaining

## Access
- Users: Read role.
- Read-only users need forking enabled: Org → Settings → Member privileges → Repository forking → allow forking of private repositories; and Repo → Settings → General → Allow forking.
- Codespaces access: Org → Settings → Codespaces → Selected members. Set a spending limit.

## Secrets
GitHub Codespaces secrets, scoped to this repo:

| Name | For |
| --- | --- |
| `LINKUP_API_KEY` | Linkup |
| `APIFY_API_KEY` | Apify |
| `NETROWS_API_KEY` | Netrows |

## Add a skill
Create `plugins/stratos-edge/skills/<name>/SKILL.md`. Commit and push.

## Add an MCP tool
Add to `mcpServers` in `plugins/stratos-edge/.claude-plugin/plugin.json`, reference its key as `${NAME}`, and add `NAME` as a Codespaces secret.
