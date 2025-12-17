#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing Ghostty config..."

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${REPO_ROOT}/dotfiles/ghostty/config"
DEST_DIR="${HOME}/.config/ghostty"
DEST="${DEST_DIR}/config"

if [[ ! -f "${SRC}" ]]; then
  log "ERROR: Missing ${SRC}"
  return 1
fi

# Ensure destination directory exists
mkdir -p "${DEST_DIR}"

# Backup existing config if it exists and differs
if [[ -f "${DEST}" ]]; then
  if cmp -s "${SRC}" "${DEST}"; then
    log "✓ Ghostty config already up to date: ${DEST}"
    return 0
  fi
  TS="$(date +"%Y%m%d-%H%M%S")"
  cp -a "${DEST}" "${DEST}.bak.${TS}"
  log "Backed up existing config to ${DEST}.bak.${TS}"
fi

cp -a "${SRC}" "${DEST}"
log "✓ Installed ${DEST}"

log "NOTE: Restart Ghostty to apply changes."
