#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing Claude Code global config..."

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${REPO_ROOT}/dotfiles/claude/settings.json"
DEST_DIR="${HOME}/.claude"
DEST="${DEST_DIR}/settings.json"

if [[ ! -f "${SRC}" ]]; then
  log "ERROR: Missing ${SRC}"
  return 1
fi

ensure_dir "${DEST_DIR}"

if [[ -f "${DEST}" ]]; then
  if cmp -s "${SRC}" "${DEST}"; then
    log "✓ Claude settings.json already up to date"
  else
    TS="$(date +"%Y%m%d-%H%M%S")"
    cp -a "${DEST}" "${DEST}.bak.${TS}"
    log "Backed up existing settings.json to ${DEST}.bak.${TS}"
    cp -a "${SRC}" "${DEST}"
    log "✓ Installed ${DEST}"
  fi
else
  cp -a "${SRC}" "${DEST}"
  log "✓ Installed ${DEST}"
fi

log "NOTE: Session-accepted permissions still go to ~/.claude/settings.local.json — not managed here."
