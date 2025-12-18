#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing database clients..."

# SQL databases
brew_install_cask dbeaver-community

# MongoDB
brew_install_cask nosqlbooster-for-mongodb
brew_install_formula mongodb-atlas-cli

log "✓ Database clients installed"
