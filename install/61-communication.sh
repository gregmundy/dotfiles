#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing communication apps..."
brew_install_cask discord
brew_install_cask zoom
log "✓ Communication apps installed"
