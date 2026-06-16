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
#    Auth itself comes from each user's CLAUDE_CODE_OAUTH_TOKEN (their Claude Team
#    seat), injected as a personal Codespaces secret — NO Anthropic API key is used.
#    This file only suppresses the onboarding/theme/trust prompts.
mkdir -p "$HOME/.claude"
cat > "$HOME/.claude.json" <<'EOF'
{
  "hasCompletedOnboarding": true,
  "hasCompletedProjectOnboarding": true,
  "hasTrustDialogAccepted": true,
  "theme": "dark"
}
EOF

# 3. Register this repo as a local plugin marketplace and install the plugin.
#    The repo is checked out locally, so no remote auth is needed.
claude plugin marketplace add "$PWD"
claude plugin install stratos-edge@stratos --scope user

# 4. Make sure session transcripts are persisted across rebuilds.
bash "$PWD/.devcontainer/persist-sessions.sh" || true

echo "Stratos Edge Claude Code environment ready."
