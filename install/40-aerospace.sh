#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing AeroSpace window manager..."

# AeroSpace is distributed via a Homebrew tap cask
brew_install_cask nikitabobko/tap/aerospace

log "✓ AeroSpace installed"
log "NOTE: You must allow Accessibility permissions for AeroSpace:"
log "      System Settings → Privacy & Security → Accessibility → enable AeroSpace"
