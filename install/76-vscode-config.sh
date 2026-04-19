#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing VS Code configs..."

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VSCODE_USER_DIR="${HOME}/Library/Application Support/Code/User"

ensure_dir "${VSCODE_USER_DIR}"

# Deploy settings.json
SRC_SETTINGS="${REPO_ROOT}/dotfiles/vscode/settings.json"
DEST_SETTINGS="${VSCODE_USER_DIR}/settings.json"

if [[ -f "${SRC_SETTINGS}" ]]; then
  if [[ -f "${DEST_SETTINGS}" ]]; then
    if cmp -s "${SRC_SETTINGS}" "${DEST_SETTINGS}"; then
      log "✓ VS Code settings.json already up to date"
    else
      TS="$(date +"%Y%m%d-%H%M%S")"
      cp -a "${DEST_SETTINGS}" "${DEST_SETTINGS}.bak.${TS}"
      log "Backed up existing settings.json"
      cp -a "${SRC_SETTINGS}" "${DEST_SETTINGS}"
      log "✓ Installed VS Code settings.json"
    fi
  else
    cp -a "${SRC_SETTINGS}" "${DEST_SETTINGS}"
    log "✓ Installed VS Code settings.json"
  fi
fi

# Deploy keybindings.json
SRC_KEYS="${REPO_ROOT}/dotfiles/vscode/keybindings.json"
DEST_KEYS="${VSCODE_USER_DIR}/keybindings.json"

if [[ -f "${SRC_KEYS}" ]]; then
  if [[ -f "${DEST_KEYS}" ]]; then
    if cmp -s "${SRC_KEYS}" "${DEST_KEYS}"; then
      log "✓ VS Code keybindings.json already up to date"
    else
      TS="$(date +"%Y%m%d-%H%M%S")"
      cp -a "${DEST_KEYS}" "${DEST_KEYS}.bak.${TS}"
      log "Backed up existing keybindings.json"
      cp -a "${SRC_KEYS}" "${DEST_KEYS}"
      log "✓ Installed VS Code keybindings.json"
    fi
  else
    cp -a "${SRC_KEYS}" "${DEST_KEYS}"
    log "✓ Installed VS Code keybindings.json"
  fi
fi

log "✓ Editor configs installed"
