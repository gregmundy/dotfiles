#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing productivity tools..."
brew_install_cask raycast
brew_install_cask obsidian
brew_install_cask notion
brew_install_cask spotify
brew_install_cask slack
brew_install_cask todoist
brew_install_cask appcleaner

log "Installing entertainment..."
brew_install_cask steam
log "✓ Productivity tools installed"
