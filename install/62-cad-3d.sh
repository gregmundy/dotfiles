#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing CAD and 3D printing tools..."

# Bambu Studio - 3D printer slicer
brew_install_cask bambu-studio

# Autodesk Fusion - CAD/CAM. Installs to ~/Applications via its own updater.
brew_install_cask autodesk-fusion

log "✓ CAD and 3D printing tools installed"
log "NOTE: Autodesk Fusion self-updates into ~/Applications and requires an Autodesk sign-in on first launch."
