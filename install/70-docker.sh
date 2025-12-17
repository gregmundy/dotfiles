#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing Docker Desktop..."
brew_install_cask docker

# Launch Docker Desktop (first-run setup)
if ! pgrep -f "Docker.app" >/dev/null 2>&1; then
  log "Launching Docker Desktop..."
  open -a Docker --background
else
  log "✓ Docker Desktop already running"
fi

# Ensure Docker starts on login
log "Ensuring Docker starts on login..."
osascript <<EOF
tell application "System Events"
  if not (exists login item "Docker") then
    make login item at end with properties {path:"/Applications/Docker.app", hidden:true}
  end if
end tell
EOF

log "✓ Docker Desktop installed and configured"
