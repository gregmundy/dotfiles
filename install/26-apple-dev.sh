#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing Apple developer tools from App Store..."

# Check if mas is available
if ! command -v mas &>/dev/null; then
  log "ERROR: mas not installed. Run 25-mas.sh first."
  return 1
fi

# Note: mas account/signin broken on macOS 12+
# Note: mas install requires sudo on macOS 14.8.2+, 15.7.2+
# User must be signed into App Store.app manually

# Refresh sudo silently (in case credential cache expired)
sudo -n true 2>/dev/null || true

# Apple Developer (640199958)
if [[ -d "/Applications/Apple Developer.app" ]]; then
  log "✓ Apple Developer already installed"
else
  log "Installing Apple Developer (may require password)..."
  sudo mas install 640199958
  log "✓ Apple Developer installed"
fi

# TestFlight (899247664)
if [[ -d "/Applications/TestFlight.app" ]]; then
  log "✓ TestFlight already installed"
else
  log "Installing TestFlight (may require password)..."
  sudo mas install 899247664
  log "✓ TestFlight installed"
fi

log "✓ Apple developer tools installed"
log "NOTE: If install failed, ensure you're signed into App Store.app"
