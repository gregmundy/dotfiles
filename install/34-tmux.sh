#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing tmux..."
brew_install_formula tmux
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
deploy_file "${REPO_ROOT}/dotfiles/tmux/tmux.conf" "${HOME}/.tmux.conf"
log "✓ tmux installed and configured"
