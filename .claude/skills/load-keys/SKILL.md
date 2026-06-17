---
name: load-keys
description: Load Stratos tool API keys from the downloaded Stratos startup package into this workspace's local settings so the MCP tools authenticate. Use when the user says they downloaded the startup package / new keys and asks to load, reload, or rotate their keys.
---

# Load API keys

Use this when a user is already set up in a Stratos workspace and wants to (re)load or rotate
their keys — e.g. they downloaded an updated `stratos-startup.md` and say "load my keys."

1. **Locate the file.** Look for the Stratos startup package `stratos-startup.md` (or a
   `stratos-keys.env`) in this order: the workspace root, the current directory, then
   `~/Downloads`. If you find none, ask the user where it is — don't guess.
2. **Extract the keys.** Read the file and pull out the `KEY=VALUE` lines — `LINKUP_API_KEY`,
   `APIFY_API_KEY`, `NETROWS_API_KEY` — ignoring any surrounding markdown, comments, or blanks.
3. **Write project-local, NOT global.** Merge each key into the `env` object of
   `.claude/settings.local.json` in the workspace root (create it if missing; leave other keys
   intact). This file is gitignored and scoped to this folder.
   - Do **not** write to `~/.claude/settings.json` (global — leaks keys into other projects).
   - Do **not** write to `.claude/settings.json` (committed/shared — commits live keys).
4. **Never print the key values, and never copy them into any committed file.**
5. Tell the user the keys are saved and to **restart Claude from this workspace folder** so the
   MCP servers pick them up.

After the restart, the `linkup`, `apify`, and `netrows` MCP servers authenticate from those keys.
