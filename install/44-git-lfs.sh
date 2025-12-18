#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing Git LFS..."
brew_install_formula git-lfs

# Check if git lfs is already configured
if git config --global --get filter.lfs.clean &>/dev/null; then
  log "✓ Git LFS already configured"
else
  log "Configuring Git LFS..."
  git lfs install
  log "✓ Git LFS configured"
fi

log "✓ Git LFS ready"
