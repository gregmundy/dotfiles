#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing Rectangle..."
brew_install_cask rectangle
log "✓ Rectangle installed"
log "NOTE: Grant Accessibility permissions when prompted on first launch."
