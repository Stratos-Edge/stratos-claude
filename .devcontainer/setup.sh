#!/usr/bin/env bash
# Runs once when the Codespace container is created (postCreate).
# The Claude Code CLI *and* the VS Code extension are installed by the official
# ghcr.io/anthropics/devcontainer-features/claude-code feature (see devcontainer.json),
# so opening the Codespace in VS Code shows the Claude panel automatically.
# This script only suppresses first-run prompts and installs the Stratos plugin.
set -euo pipefail

# 1. Suppress the onboarding/theme/trust prompts. (~/.claude.json sits at the home
#    root, which is NOT on the persisted ~/.claude volume, so re-create it each build.)
#    Auth itself comes from CLAUDE_CODE_OAUTH_TOKEN (the user's Claude Team seat),
#    injected as a personal Codespaces secret.
cat > "$HOME/.claude.json" <<'EOF'
{
  "hasCompletedOnboarding": true,
  "hasCompletedProjectOnboarding": true,
  "hasTrustDialogAccepted": true,
  "theme": "dark"
}
EOF

# 2. Register this repo as a local plugin marketplace and install the plugin
#    (idempotent across rebuilds).
claude plugin marketplace add "$PWD" || true
claude plugin install stratos-edge@stratos --scope user || true

echo "Stratos Edge Claude Code environment ready."
