#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

# uv itself comes from the Brewfile.
if ! command -v uv >/dev/null 2>&1; then
  log "ERROR: uv not found — run './setup.sh brewfile' first."
  return 1
fi

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
