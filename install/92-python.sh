#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing uv (Python package/version manager)..."
brew_install_formula uv

log "Installing Python versions via uv..."

# Helper to check if Python version is installed
uv_has_python() {
  uv python list --only-installed 2>/dev/null | grep -q "cpython-$1"
}

# Install Python versions if not present
for version in 3.12 3.13; do
  if uv_has_python "$version"; then
    log "✓ Python $version already installed"
  else
    uv python install "$version"
    log "✓ Python $version installed"
  fi
done

log "✓ Python/uv setup complete"
log ""
log "Usage:"
log "  uv python install 3.11      # Install a specific version"
log "  uv python list              # List available versions"
log "  uv venv                     # Create virtualenv in current dir"
log "  uv pip install <pkg>        # Install packages (in venv)"
log "  uv run python script.py     # Run with auto-created venv"
log "  uv init                     # Initialize a new project"
