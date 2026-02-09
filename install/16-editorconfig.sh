#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Deploying .editorconfig..."

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${REPO_ROOT}/dotfiles/editorconfig"
DEST="${HOME}/.editorconfig"

if [[ ! -f "${SRC}" ]]; then
  log "ERROR: Missing ${SRC}"
  return 1
fi

if [[ -f "${DEST}" ]]; then
  if cmp -s "${SRC}" "${DEST}"; then
    log "✓ .editorconfig already up to date"
  else
    TS="$(date +"%Y%m%d-%H%M%S")"
    cp -a "${DEST}" "${DEST}.bak.${TS}"
    log "Backed up existing .editorconfig to ${DEST}.bak.${TS}"
    cp -a "${SRC}" "${DEST}"
    log "✓ Installed ${DEST}"
  fi
else
  cp -a "${SRC}" "${DEST}"
  log "✓ Installed ${DEST}"
fi
