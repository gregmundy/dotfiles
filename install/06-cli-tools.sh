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

# Code formatting/linting
brew_install_formula biome

# Git TUI
brew_install_formula lazygit

# Docker TUI
brew_install_formula lazydocker

# Smarter cd with frecency
brew_install_formula zoxide

# Simplified man pages
brew_install_formula tldr

# HTTP client
brew_install_formula httpie

# Better git diffs
brew_install_formula git-delta

# Interactive JSON viewer
brew_install_formula jless

# Cross-shell prompt
brew_install_formula starship

log "✓ CLI tools installed"
