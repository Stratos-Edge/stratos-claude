#!/usr/bin/env bash
# Runs once when the Codespace container is created (postCreate).
# Installs Claude Code, pre-seeds a prompt-free first run, and installs the plugin.
set -euo pipefail

# 1. Install Claude Code if it isn't already present.
if ! command -v claude >/dev/null 2>&1; then
  curl -fsSL https://claude.ai/install.sh | bash
fi
export PATH="$HOME/.local/bin:$PATH"
# Make the CLI available in interactive shells too.
if ! grep -q '.local/bin' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

# 2. Pre-seed ~/.claude.json so the first interactive session has no prompts.
#    Claude stores approval of a custom API key as the LAST 20 CHARACTERS of the key.
#    ANTHROPIC_API_KEY is injected by Codespaces secrets; if it's missing, the key
#    simply won't be pre-approved (Claude will prompt once).
mkdir -p "$HOME/.claude"
KEY_TAIL=""
if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  KEY_TAIL="${ANTHROPIC_API_KEY: -20}"
fi
cat > "$HOME/.claude.json" <<EOF
{
  "hasCompletedOnboarding": true,
  "hasCompletedProjectOnboarding": true,
  "hasTrustDialogAccepted": true,
  "theme": "dark",
  "customApiKeyResponses": { "approved": ["$KEY_TAIL"], "rejected": [] }
}
EOF

# 3. Register this repo as a local plugin marketplace and install the plugin.
#    The repo is checked out locally, so no remote auth is needed.
claude plugin marketplace add "$PWD"
claude plugin install stratos-edge@stratos --scope user

# 4. Make sure session transcripts are persisted across rebuilds.
bash "$PWD/.devcontainer/persist-sessions.sh" || true

echo "Stratos Edge Claude Code environment ready."
