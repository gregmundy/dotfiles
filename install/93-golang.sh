#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing Go..."
brew_install_formula go

# Check if go is available (might need PATH update on first install)
if command -v go &>/dev/null; then
  log "✓ Go installed: $(go version)"
else
  log "✓ Go installed (restart terminal to use)"
fi

