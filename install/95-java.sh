#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing Java (Eclipse Temurin)..."
brew_install_cask temurin

if /usr/libexec/java_home &>/dev/null; then
  log "✓ Java installed: $(/usr/libexec/java_home --version 2>&1 | head -1 || echo 'available')"
else
  log "✓ Java installed (restart terminal to use)"
fi
