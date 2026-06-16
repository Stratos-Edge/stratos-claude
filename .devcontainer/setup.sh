#!/usr/bin/env bash
# postCreate: runs when the Codespace container is created (and on rebuild).
# The Claude Code CLI + VS Code extension are installed by the official
# ghcr.io/anthropics/devcontainer-features/claude-code feature (see devcontainer.json).
# This script fixes the ~/.claude volume permissions, pre-seeds a prompt-free first
# run, and installs the Stratos plugin (which carries the linkup/apify/netrows MCP
# servers).
set -euo pipefail

# 0. Fix ownership of the mounted ~/.claude volume. Docker creates named volumes owned
#    by root, but the container runs as a non-root user — so without this, writes to
#    ~/.claude fail with EACCES, which blocks the plugin install, credential storage,
#    and session state (e.g. ~/.claude/session-env). This is the root cause of the
#    plugin/MCP servers not appearing.
sudo chown -R "$(id -un):$(id -gn)" "$HOME/.claude" 2>/dev/null \
  || echo "WARN: could not chown ~/.claude (sudo unavailable?) — plugin install may fail."
mkdir -p "$HOME/.claude"

# 1. Make sure the Claude CLI is callable (installed by the devcontainer feature).
if ! command -v claude >/dev/null 2>&1; then
  echo "ERROR: 'claude' not found on PATH — the devcontainer feature may not have installed it." >&2
  exit 1
fi

# 2. Suppress onboarding/theme/trust prompts and pre-approve the injected
#    ANTHROPIC_API_KEY (Claude records approval as the key's last 20 characters).
#    ANTHROPIC_API_KEY + the tool keys (LINKUP/APIFY/NETROWS) are injected by
#    Codespaces secrets.
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
#    Failures are logged (not silently swallowed with '|| true') so they surface
#    in the build log.
claude plugin marketplace add "$PWD" 2>&1 \
  || echo "NOTE: 'plugin marketplace add' returned nonzero (often it's already added)."
claude plugin install stratos-edge@stratos --scope user 2>&1 \
  || echo "ERROR: 'plugin install' failed — the MCP servers will be missing."

echo "Stratos Edge setup done. Installed plugins:"
claude plugin list 2>&1 || true
