#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Ensuring Command Line Tools are installed..."
brew_ensure_clt

log "Ensuring Homebrew is installed..."
brew_ensure

# One explicit update here. setup.sh exports HOMEBREW_NO_AUTO_UPDATE=1 so the
# individual installs below don't each re-run it (and don't stall on it).
log "Updating Homebrew..."
run brew update
log "✓ Homebrew ready"
