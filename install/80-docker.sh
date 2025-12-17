#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

brew_install_cask docker

# Launch Docker Desktop (first-run setup)
if ! pgrep -f "Docker.app" >/dev/null 2>&1; then
  echo "==> Launching Docker Desktop..."
  open -a Docker --background
else
  echo "✓ Docker Desktop already running"
fi

# Ensure Docker starts on login
echo "==> Ensuring Docker starts on login..."
osascript <<EOF
tell application "System Events"
  if not (exists login item "Docker") then
    make login item at end with properties {path:"/Applications/Docker.app", hidden:true}
  end if
end tell
EOF

echo "✓ Docker Desktop installed and configured"

