#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing AeroSpace config..."

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${REPO_ROOT}/dotfiles/aerospace/aerospace.toml"
DEST="${HOME}/.aerospace.toml"

if [[ ! -f "${SRC}" ]]; then
  log "ERROR: Missing ${SRC}"
  return 1
fi

# Backup existing config if it exists and differs
if [[ -f "${DEST}" ]]; then
  if cmp -s "${SRC}" "${DEST}"; then
    log "✓ AeroSpace config already up to date: ${DEST}"
    return 0
  fi
  TS="$(date +"%Y%m%d-%H%M%S")"
  cp -a "${DEST}" "${DEST}.bak.${TS}"
  log "Backed up existing config to ${DEST}.bak.${TS}"
fi

cp -a "${SRC}" "${DEST}"
log "✓ Installed ${DEST}"

log "NOTE: If AeroSpace is running, reload config (AeroSpace menu → Reload Config)."
