#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing Git LFS..."
brew_install_formula git-lfs

log "Configuring Git LFS..."
git lfs install

log "✓ Git LFS installed and configured"
