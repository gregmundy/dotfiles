#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing VS Code configs..."

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VSCODE_USER_DIR="${HOME}/Library/Application Support/Code/User"

# Ensure VS Code user directory exists
if [[ ! -d "${VSCODE_USER_DIR}" ]]; then
  log "VS Code user directory not found. Is VS Code installed?"
  log "Creating directory: ${VSCODE_USER_DIR}"
  mkdir -p "${VSCODE_USER_DIR}"
fi

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

# Deploy global editorconfig
SRC_EDITOR="${REPO_ROOT}/dotfiles/editorconfig"
DEST_EDITOR="${HOME}/.editorconfig"

if [[ -f "${SRC_EDITOR}" ]]; then
  if [[ -f "${DEST_EDITOR}" ]]; then
    if cmp -s "${SRC_EDITOR}" "${DEST_EDITOR}"; then
      log "✓ .editorconfig already up to date"
    else
      TS="$(date +"%Y%m%d-%H%M%S")"
      cp -a "${DEST_EDITOR}" "${DEST_EDITOR}.bak.${TS}"
      log "Backed up existing .editorconfig"
      cp -a "${SRC_EDITOR}" "${DEST_EDITOR}"
      log "✓ Installed ${DEST_EDITOR}"
    fi
  else
    cp -a "${SRC_EDITOR}" "${DEST_EDITOR}"
    log "✓ Installed ${DEST_EDITOR}"
  fi
fi

log "✓ Editor configs installed"
