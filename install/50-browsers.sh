#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing browsers..."
brew_install_cask google-chrome
brew_install_cask duckduckgo
log "✓ Browsers installed"
