---
name: load-keys
description: Load Stratos tool API keys from a dropped env file into Claude's user settings so the MCP tools authenticate. Use when the user drops or mentions an env file of API keys (e.g. stratos-keys.env).
---

# Load API keys

When the user has dropped an env file of API keys into the working folder (e.g. `stratos-keys.env`, shared via 1Password) and asks to load / set up their keys:

1. Read that env file. It contains lines like `LINKUP_API_KEY=...`, `APIFY_API_KEY=...`, `NETROWS_API_KEY=...`.
2. Merge each `KEY=VALUE` into the `env` object of the user's global settings at `~/.claude/settings.json` — create the file or the `env` object if missing, and do not overwrite unrelated keys. (`~/.claude` is a protected path, so approve the one-time settings edit when prompted.)
3. Never print the key values, and never copy them into this repo.
4. Tell the user the keys are saved and to **restart the Claude session** so the MCP servers pick them up.

After the restart, the `linkup`, `apify`, and `netrows` tools authenticate from those keys.
