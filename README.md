# Stratos Edge — Claude Code Capability Package

A private repo that is two things at once:

1. A **Claude Code plugin marketplace + plugin** (`stratos-edge`) — the curated Stratos toolset: skills, slash commands, agents, and MCP servers (starting with **Linkup** web search).
2. A **GitHub Codespace template** — open it as a Codespace and Claude Code launches fully installed, pre-authenticated, and loaded with the plugin. **Zero local setup.**

Each person opens their **own isolated Codespace** from this repo. Your sessions and work live only in your container — this repo stays a clean, read-only capability library and never receives anyone's work.

---

## For teammates — one-time setup (~3 min)

You set **three secrets once** on your own GitHub account (Codespaces *user* secrets), scoped to this repo. Ask Peat for the values.

**Option A — GitHub web UI**
`github.com/settings/codespaces` → **Codespaces secrets** → **New secret**. For each, set *Repository access* to `peatlaughlin/stratos-claude`:
- `ANTHROPIC_API_KEY`
- `LINKUP_API_KEY`
- `NETROWS_API_KEY` *(once provided)*

**Option B — `gh` CLI**
```bash
gh secret set ANTHROPIC_API_KEY --user --app codespaces --repos peatlaughlin/stratos-claude
gh secret set LINKUP_API_KEY    --user --app codespaces --repos peatlaughlin/stratos-claude
```

**Set auto-delete to 30 days** so idle Codespaces self-clean but nothing disappears sooner:
`github.com/settings/codespaces` → **Default retention period** → `30 days`.

Then open this repo → **Code ▸ Codespaces ▸ Create codespace**. Wait ~1–2 min for setup, then run `claude`.

---

## Daily use

- Run `claude`. Sessions persist across stop/start **and** container rebuilds.
- Idle Codespaces stop (pause) after 30 min — nothing is lost — and are deleted only after **30 days unused**.
- **To get the latest tools:** rebuild the container (`Cmd/Ctrl+Shift+P` → *Codespaces: Rebuild Container*) or create a fresh Codespace.

---

## What's inside

| Path | Purpose |
| --- | --- |
| `plugins/stratos-edge/` | The plugin: `skills/`, `commands/`, `agents/`, and `plugin.json` (MCP servers) |
| `.claude-plugin/marketplace.json` | Marketplace manifest (makes this repo installable) |
| `.devcontainer/` | Codespace setup — installs Claude Code + the plugin, persists sessions |

---

## For maintainers — adding capabilities

- **Skill:** create `plugins/stratos-edge/skills/<name>/SKILL.md` (see `example-skill`). Commit + push; teammates rebuild to pick it up.
- **Command / agent:** drop a `.md` file in `commands/` or `agents/`.
- **MCP server:** add an entry to `mcpServers` in `plugins/stratos-edge/.claude-plugin/plugin.json`, referencing its key as `${SOME_KEY}`, and have everyone add `SOME_KEY` as a Codespaces secret.

### Adding Netrows (pending its package/URL)

Once we have the Netrows MCP details, add **one** of these to `mcpServers` in `plugin.json`:

```jsonc
// stdio (npm package)
"netrows": {
  "command": "npx",
  "args": ["-y", "<netrows-package>"],
  "env": { "NETROWS_API_KEY": "${NETROWS_API_KEY}" }
}
```
```jsonc
// hosted HTTP
"netrows": {
  "type": "http",
  "url": "<netrows-mcp-url>",
  "headers": { "Authorization": "Bearer ${NETROWS_API_KEY}" }
}
```
Then everyone adds `NETROWS_API_KEY` as a Codespaces secret.

---

## Secrets reference

| Secret | Purpose |
| --- | --- |
| `ANTHROPIC_API_KEY` | Authenticates Claude Code (central key) |
| `LINKUP_API_KEY` | Linkup web-search MCP |
| `NETROWS_API_KEY` | Netrows MCP *(pending)* |

Secrets are **never** stored in this repo — only referenced as `${...}` and injected by Codespaces at runtime.

---

## Migrating to the Stratos org (later)

When the org exists, the plugin and devcontainer **don't change** — migration is platform-only:
1. Transfer this repo to the org (preserves history).
2. Recreate the three keys as **org-level** Codespaces secrets scoped to the repo → the per-person secret step disappears (true zero-touch).
3. Set org policies: who can create Codespaces (Selected members), allowed machine types, retention cap = 30 days, and a Codespaces **spending limit**. Central billing + audit.
