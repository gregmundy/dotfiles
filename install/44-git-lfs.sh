#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

# git-lfs itself comes from the Brewfile; this registers its git hooks.
if ! command -v git-lfs &>/dev/null; then
  log "ERROR: git-lfs not found — run './setup.sh brewfile' first."
  return 1
fi

# Check if git lfs is already configured
if git config --global --get filter.lfs.clean &>/dev/null; then
  log "✓ Git LFS already configured"
else
  log "Configuring Git LFS..."
  git lfs install
  log "✓ Git LFS configured"
fi

log "✓ Git LFS ready"
