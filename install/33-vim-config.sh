#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing vim/neovim configs..."
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
deploy_file "${REPO_ROOT}/dotfiles/vim/vimrc" "${HOME}/.vimrc"
deploy_file "${REPO_ROOT}/dotfiles/nvim/init.lua" "${HOME}/.config/nvim/init.lua"
log "✓ Vim/Neovim configs installed"
