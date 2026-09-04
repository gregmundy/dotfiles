#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing Docker Desktop..."
brew_install_cask docker-desktop

# Launch Docker Desktop (first-run setup)
if ! pgrep -f "Docker.app" >/dev/null 2>&1; then
  log "Launching Docker Desktop..."
  run open -a Docker --background
else
  log "✓ Docker Desktop already running"
fi

# Start on login. Query first so re-runs and dry runs are quiet.
add_docker_login_item() {
  osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Docker.app", hidden:true}' >/dev/null  # dry-run: safe (called via run)
}
if osascript -e 'tell application "System Events" to get name of every login item' 2>/dev/null | grep -qw Docker; then
  log "✓ Docker already starts on login"
else
  log "Ensuring Docker starts on login..."
  run add_docker_login_item
fi

log "✓ Docker Desktop installed and configured"
