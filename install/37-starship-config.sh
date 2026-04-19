#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing Starship config..."

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${REPO_ROOT}/dotfiles/starship/starship.toml"
DEST_DIR="${HOME}/.config"
DEST="${DEST_DIR}/starship.toml"

if [[ ! -f "${SRC}" ]]; then
  log "ERROR: Missing ${SRC}"
  return 1
fi

ensure_dir "${DEST_DIR}"

if [[ -f "${DEST}" ]]; then
  if cmp -s "${SRC}" "${DEST}"; then
    log "✓ starship.toml already up to date"
  else
    TS="$(date +"%Y%m%d-%H%M%S")"
    cp -a "${DEST}" "${DEST}.bak.${TS}"
    log "Backed up existing starship.toml to ${DEST}.bak.${TS}"
    cp -a "${SRC}" "${DEST}"
    log "✓ Installed ${DEST}"
  fi
else
  cp -a "${SRC}" "${DEST}"
  log "✓ Installed ${DEST}"
fi

log "NOTE: Open a new shell to see the new prompt."
