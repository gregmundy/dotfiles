#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing git configs..."

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Deploy gitconfig
SRC_CONFIG="${REPO_ROOT}/dotfiles/git/gitconfig"
DEST_CONFIG="${HOME}/.gitconfig"

if [[ ! -f "${SRC_CONFIG}" ]]; then
  log "ERROR: Missing ${SRC_CONFIG}"
  return 1
fi

if [[ -f "${DEST_CONFIG}" ]]; then
  if cmp -s "${SRC_CONFIG}" "${DEST_CONFIG}"; then
    log "✓ gitconfig already up to date"
  else
    TS="$(date +"%Y%m%d-%H%M%S")"
    cp -a "${DEST_CONFIG}" "${DEST_CONFIG}.bak.${TS}"
    log "Backed up existing gitconfig to ${DEST_CONFIG}.bak.${TS}"
    cp -a "${SRC_CONFIG}" "${DEST_CONFIG}"
    log "✓ Installed ${DEST_CONFIG}"
  fi
else
  cp -a "${SRC_CONFIG}" "${DEST_CONFIG}"
  log "✓ Installed ${DEST_CONFIG}"
fi

# Deploy gitignore_global
SRC_IGNORE="${REPO_ROOT}/dotfiles/git/gitignore_global"
DEST_IGNORE="${HOME}/.gitignore_global"

if [[ ! -f "${SRC_IGNORE}" ]]; then
  log "ERROR: Missing ${SRC_IGNORE}"
  return 1
fi

if [[ -f "${DEST_IGNORE}" ]]; then
  if cmp -s "${SRC_IGNORE}" "${DEST_IGNORE}"; then
    log "✓ gitignore_global already up to date"
  else
    TS="$(date +"%Y%m%d-%H%M%S")"
    cp -a "${DEST_IGNORE}" "${DEST_IGNORE}.bak.${TS}"
    log "Backed up existing gitignore_global to ${DEST_IGNORE}.bak.${TS}"
    cp -a "${SRC_IGNORE}" "${DEST_IGNORE}"
    log "✓ Installed ${DEST_IGNORE}"
  fi
else
  cp -a "${SRC_IGNORE}" "${DEST_IGNORE}"
  log "✓ Installed ${DEST_IGNORE}"
fi

log "NOTE: Update ~/.gitconfig with your name and email!"
