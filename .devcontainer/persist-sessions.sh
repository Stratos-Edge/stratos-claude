#!/usr/bin/env bash
# Runs on every Codespace start (postStart).
# /workspaces survives container rebuilds; the home dir does not. Symlinking the
# Claude session transcripts into /workspaces keeps sessions alive across rebuilds.
# (Only an actual 30-day deletion of the Codespace clears them — the desired behavior.)
# NOTE: only the transcripts are persisted — credentials/API keys are never written here.
set -euo pipefail

mkdir -p /workspaces/.claude-sessions "$HOME/.claude"

if [ ! -L "$HOME/.claude/projects" ]; then
  rm -rf "$HOME/.claude/projects"
  ln -sfn /workspaces/.claude-sessions "$HOME/.claude/projects"
fi
