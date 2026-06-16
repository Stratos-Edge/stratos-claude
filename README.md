# Stratos Edge — Claude Code Capability Package

A private repo that is two things at once:

1. A **Claude Code plugin marketplace + plugin** (`stratos-edge`) — the curated Stratos toolset: skills, slash commands, agents, and MCP servers (starting with **Linkup** web search).
2. A **GitHub Codespace template** — open it as a Codespace and Claude Code launches installed, authenticated with **your own Claude Team seat**, and loaded with the plugin.

Each person opens their **own isolated Codespace** (its own private VM) from this repo. Your sessions and work live only in your container — the repo stays a read-only capability library and never receives anyone's work.

---

## Access model — who can do what

- **Users get the `Read` role.** They can launch a Codespace from the repo but **cannot change it.** Any commits they make inside their Codespace auto-divert to *their own private fork*; the canonical repo only changes via a pull request an owner approves.
- **Forking must be enabled** for the repo (org setting). This is the single setting that lets Read-only users launch Codespaces — and it exposes nothing beyond what `Read` already allows.
- **Codespaces access = "Selected members"** (org setting) — only the people you choose.

---

## For teammates — one-time setup (~5–10 min)

1. **Accept the repo invite** (Read access). Enable 2FA if prompted.
2. **Authenticate Claude with your Team seat:** on any machine with a browser, log into your Stratos Claude Team account and run:
   ```bash
   claude setup-token
   ```
   Copy the token it prints (valid ~1 year).
3. **Store it as your personal Codespaces secret** named `CLAUDE_CODE_OAUTH_TOKEN`, scoped to this repo:
   - Web: `github.com/settings/codespaces` → **Codespaces secrets** → **New secret**, or
   - CLI: `gh secret set CLAUDE_CODE_OAUTH_TOKEN --user --app codespaces --repos Stratos-Edge/stratos-claude`
4. **Set auto-delete to 30 days:** `github.com/settings/codespaces` → **Default retention period** → `30 days`.

Then open the repo → **Code ▸ Codespaces ▸ Create codespace**. After ~1–2 min, run `claude` — the tools and skills are loaded and you're authenticated via your Team seat.

> The shared tool keys (Linkup, etc.) are injected automatically as **org** secrets — you don't set those. The only secret you manage is your own `CLAUDE_CODE_OAUTH_TOKEN`.

---

## Daily use

- Run `claude`. Sessions persist across stop/start **and** container rebuilds.
- Idle Codespaces pause after 30 min (no data loss) and delete only after **30 days unused**.
- **To get the latest tools:** rebuild the container (`Cmd/Ctrl+Shift+P` → *Codespaces: Rebuild Container*) or create a fresh Codespace.

---

## What's inside

| Path | Purpose |
| --- | --- |
| `plugins/stratos-edge/` | The plugin: `skills/`, `commands/`, `agents/`, and `plugin.json` (MCP servers) |
| `.claude-plugin/marketplace.json` | Marketplace manifest |
| `.devcontainer/` | Codespace setup — installs Claude Code + the plugin, persists sessions |

---

## For maintainers / admins

**One-time org setup:**
- Repo role = **Read** for users; **enable private-repo forking**; Codespaces access = **Selected members**.
- Set the shared tool keys as **org-level** Codespaces secrets scoped to this repo (set once, everyone gets them — no per-user action): `LINKUP_API_KEY` (+ `NETROWS_API_KEY` later).
- Set a Codespaces **spending limit**; optionally restrict machine types and set a retention policy.

**Adding capabilities:**
- **Skill:** create `plugins/stratos-edge/skills/<name>/SKILL.md` (see `example-skill`). Commit + push; teammates rebuild.
- **Command / agent:** drop a `.md` in `commands/` or `agents/`.
- **MCP server:** add an entry to `mcpServers` in `plugins/stratos-edge/.claude-plugin/plugin.json`, referencing its key as `${SOME_KEY}`, and add `SOME_KEY` as an org Codespaces secret.

### Adding Netrows (pending its package/URL)

Add **one** of these to `mcpServers` in `plugin.json`, then set `NETROWS_API_KEY` as an org secret:

```jsonc
// stdio (npm package)
"netrows": { "command": "npx", "args": ["-y", "<netrows-package>"],
             "env": { "NETROWS_API_KEY": "${NETROWS_API_KEY}" } }
```
```jsonc
// hosted HTTP
"netrows": { "type": "http", "url": "<netrows-mcp-url>",
             "headers": { "Authorization": "Bearer ${NETROWS_API_KEY}" } }
```

---

## Secrets reference

| Secret | Level | Purpose |
| --- | --- | --- |
| `CLAUDE_CODE_OAUTH_TOKEN` | **per-user** | Authenticates Claude Code via the user's Claude Team seat (`claude setup-token`, ~1 yr) |
| `LINKUP_API_KEY` | **org** | Linkup web-search MCP (shared Stratos key) |
| `NETROWS_API_KEY` | **org** | Netrows MCP *(pending)* |

No Anthropic API key is used. Secrets are never stored in this repo — only referenced as `${...}` and injected by Codespaces at runtime.
