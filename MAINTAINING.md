# Maintaining the Stratos Edge Claude package

This repo is both a **Claude Code plugin marketplace + plugin** (`stratos-edge`) and a **GitHub Codespace template**. End users open a Codespace and get the curated toolset pre-installed and pre-authenticated — see [README.md](README.md) for their view. This doc is for maintainers.

## Access model — "use it, can't alter it"

- Users get the **Read** role (not Write): they can launch a Codespace but cannot change the repo. Any commits they make in their Codespace auto-divert to their **own private fork**; the canonical repo changes only via a PR an owner approves.
- **Forking must be enabled** or Read-only users can't launch a Codespace at all (Read + no-fork = hard blocker):
  - Org → Settings → **Member privileges → Repository forking** → enable *Allow forking of private repositories* (needs `admin:org`), **and**
  - the repo's **Allow forking** toggle (Settings → General).
  - To scope it, leave the org policy on but set `allow_forking=false` on other private repos you don't want forkable.
- Org **Codespaces access = "Selected members"** — only the people you choose. Owners (Peat, Micah) keep Owner/Write to push capability updates.

## Auth — bring-your-own Claude Team seat

Each user authenticates with their **own Claude Team seat** (no central API key).

- **Simplest:** in the Codespace terminal, run `claude` and sign in once. If the browser callback doesn't route back (common in Codespaces), it shows a **code** — paste it at the terminal prompt. Credentials persist via the `~/.claude` volume, so it's a one-time step.
- **Zero-touch alternative:** the user runs `claude setup-token` (on a machine where browser login works), then stores the token as their **personal** Codespaces secret `CLAUDE_CODE_OAUTH_TOKEN`. Note: the VS Code extension reads the saved credentials file, not the env var, so `claude` must run once in the container to seed it.
- **Never set `ANTHROPIC_API_KEY`** — it takes precedence and breaks subscription auth.

## Secrets

| Secret | Level | Purpose |
| --- | --- | --- |
| `CLAUDE_CODE_OAUTH_TOKEN` | per-user | Claude auth (user's Team seat) |
| `LINKUP_API_KEY` | org | Linkup web-search MCP (shared) |
| `APIFY_API_KEY` | org | Apify Actors MCP — web scraping/automation (the value is your Apify *API token*) |
| `NETROWS_API_KEY` | org | Netrows MCP *(pending package/URL)* |

Store shared keys as **org** Codespaces secrets scoped to this repo. 1Password is the source of truth for the canonical values; mirror them into the GitHub secret. Never commit secrets — they're referenced as `${...}` and injected by Codespaces.

## Adding capabilities

- **Skill:** create `plugins/stratos-edge/skills/<name>/SKILL.md` (see `example-skill`). Commit + push; users rebuild.
- **Command / agent:** drop a `.md` in `commands/` or `agents/`.
- **MCP server:** add to `mcpServers` in `plugins/stratos-edge/.claude-plugin/plugin.json`, referencing its key as `${SOME_KEY}`, and add `SOME_KEY` as an org secret.

### Adding Netrows (pending package/URL)
```jsonc
// stdio:  "netrows": { "command": "npx", "args": ["-y", "<pkg>"],
//                      "env": { "NETROWS_API_KEY": "${NETROWS_API_KEY}" } }
// http:   "netrows": { "type": "http", "url": "<url>",
//                      "headers": { "Authorization": "Bearer ${NETROWS_API_KEY}" } }
```

## VS Code UX (devcontainer customizations)

Set in `.devcontainer/devcontainer.json` under `customizations.vscode`:
- **Copilot hidden:** excluded via `-github.copilot` / `-github.copilot-chat`, plus `chat.disableAIFeatures: true` (disables only Copilot's AI/chat; the Claude panel is a separate extension, untouched). **Caveat:** a user on VS Code *Desktop* with Settings Sync may have Copilot re-added from their own account — cleanest in the **browser**.
- `workbench.startupEditor: none` (no welcome tab); `terminal.integrated.hideOnStartup: always` (best-effort).
- **Claude panel auto-open on launch is not reliably supported** by the extension — it's installed and one click away, not auto-popped.

## How it's built

- `.devcontainer/devcontainer.json` — official `ghcr.io/anthropics/devcontainer-features/claude-code` feature (installs the CLI **and** the VS Code extension) + a named volume on `~/.claude` (persists auth/sessions across rebuilds) + the UX customizations above.
- `.devcontainer/setup.sh` — pre-seeds a prompt-free first run and installs the `stratos-edge` plugin from the local checkout.
- `.claude-plugin/marketplace.json` — marketplace manifest.
