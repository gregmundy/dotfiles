#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing development IDEs and tools..."
brew_install_cask pycharm
brew_install_cask visual-studio-code
brew_install_cask cursor
brew_install_cask cursor-cli
brew_install_cask claude-code
log "✓ Development IDEs installed"
