#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing API testing tools..."
brew_install_cask postman
brew_install_cask insomnia

# ngrok - public tunnels to localhost, for webhook testing
brew_install_cask ngrok

log "✓ API tools installed"
log "NOTE: ngrok needs an authtoken before first use: ngrok config add-authtoken <token>"
