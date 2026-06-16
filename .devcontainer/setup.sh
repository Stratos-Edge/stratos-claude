#!/usr/bin/env bash
# Runs once when the Codespace container is created (postCreate).
# The Claude Code CLI *and* the VS Code extension are installed by the official
# ghcr.io/anthropics/devcontainer-features/claude-code feature (see devcontainer.json),
# so opening the Codespace in VS Code shows the Claude panel automatically.
# This script only suppresses first-run prompts and installs the Stratos plugin.
set -euo pipefail

# 1. Suppress the onboarding/theme/trust prompts AND pre-approve the injected
#    ANTHROPIC_API_KEY so there's no one-time "approve this key?" prompt. Claude
#    records key approval as the key's LAST 20 CHARACTERS.
#    (~/.claude.json sits at the home root, NOT on the persisted ~/.claude volume,
#    so it's re-created each build. ANTHROPIC_API_KEY and the tool keys
#    [LINKUP/APIFY/NETROWS] are injected automatically by the Codespaces secrets.)
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

# 2. Register this repo as a local plugin marketplace and install the plugin
#    (idempotent across rebuilds).
claude plugin marketplace add "$PWD" || true
claude plugin install stratos-edge@stratos --scope user || true

echo "Stratos Edge Claude Code environment ready."
