#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing Neovim..."
brew_install_formula neovim

log "✓ Neovim installed"
log "NOTE: Run 'nvim' to start Neovim."
