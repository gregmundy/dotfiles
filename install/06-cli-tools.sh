#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing CLI tools..."

# JSON/YAML processing
brew_install_formula jq
brew_install_formula yq

# Search and navigation
brew_install_formula fzf
brew_install_formula ripgrep
brew_install_formula bat
brew_install_formula eza

# GitHub CLI
brew_install_formula gh

# System monitoring
brew_install_formula btop

log "✓ CLI tools installed"
