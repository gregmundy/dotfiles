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

log ""
log "Usage:"
log "  go mod init myproject   # Initialize a new module"
log "  go run main.go          # Run a program"
log "  go build                # Compile"
log "  go get <pkg>            # Add dependency"
log "  go install <pkg>@latest # Install a tool globally"
