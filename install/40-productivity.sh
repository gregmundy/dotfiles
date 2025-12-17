#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing productivity tools..."
brew_install_cask raycast
brew_install_cask obsidian
brew_install_cask notion
log "✓ Productivity tools installed"
