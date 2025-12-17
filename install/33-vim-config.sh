#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing vim/neovim configs..."

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Deploy vimrc
SRC_VIMRC="${REPO_ROOT}/dotfiles/vim/vimrc"
DEST_VIMRC="${HOME}/.vimrc"

if [[ -f "${SRC_VIMRC}" ]]; then
  if [[ -f "${DEST_VIMRC}" ]]; then
    if cmp -s "${SRC_VIMRC}" "${DEST_VIMRC}"; then
      log "✓ .vimrc already up to date"
    else
      TS="$(date +"%Y%m%d-%H%M%S")"
      cp -a "${DEST_VIMRC}" "${DEST_VIMRC}.bak.${TS}"
      log "Backed up existing .vimrc"
      cp -a "${SRC_VIMRC}" "${DEST_VIMRC}"
      log "✓ Installed ${DEST_VIMRC}"
    fi
  else
    cp -a "${SRC_VIMRC}" "${DEST_VIMRC}"
    log "✓ Installed ${DEST_VIMRC}"
  fi
fi

# Deploy neovim config
SRC_NVIM="${REPO_ROOT}/dotfiles/nvim/init.lua"
DEST_NVIM_DIR="${HOME}/.config/nvim"
DEST_NVIM="${DEST_NVIM_DIR}/init.lua"

if [[ -f "${SRC_NVIM}" ]]; then
  mkdir -p "${DEST_NVIM_DIR}"

  if [[ -f "${DEST_NVIM}" ]]; then
    if cmp -s "${SRC_NVIM}" "${DEST_NVIM}"; then
      log "✓ Neovim init.lua already up to date"
    else
      TS="$(date +"%Y%m%d-%H%M%S")"
      cp -a "${DEST_NVIM}" "${DEST_NVIM}.bak.${TS}"
      log "Backed up existing init.lua"
      cp -a "${SRC_NVIM}" "${DEST_NVIM}"
      log "✓ Installed ${DEST_NVIM}"
    fi
  else
    cp -a "${SRC_NVIM}" "${DEST_NVIM}"
    log "✓ Installed ${DEST_NVIM}"
  fi
fi

log "✓ Vim/Neovim configs installed"
