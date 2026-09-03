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

# Install extensions listed in dotfiles/vscode/extensions.txt
SRC_EXTS="${REPO_ROOT}/dotfiles/vscode/extensions.txt"

# Resolve the `code` CLI. It is on PATH when the cask's shim is linked, but fall
# back to the binary inside the app bundle so a fresh install works before the
# user has opened VS Code once.
CODE_BIN=""
if command -v code &>/dev/null; then
  CODE_BIN="code"
elif [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
  CODE_BIN="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
fi

if [[ -f "${SRC_EXTS}" && -n "${CODE_BIN}" ]]; then
  log "Installing VS Code extensions..."

  # Query the installed set once — `code --install-extension` is slow enough
  # that per-extension probing noticeably drags out setup.
  INSTALLED_EXTS="$("${CODE_BIN}" --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]' || true)"

  while IFS= read -r ext || [[ -n "${ext}" ]]; do
    # Strip comments and surrounding whitespace; skip blanks.
    ext="${ext%%#*}"
    ext="$(echo "${ext}" | xargs || true)"
    [[ -z "${ext}" ]] && continue

    if grep -qxF "$(echo "${ext}" | tr '[:upper:]' '[:lower:]')" <<< "${INSTALLED_EXTS}"; then
      ui_skip "${ext}"
    else
      ui_spin "Installing ${ext}..." "${CODE_BIN}" --install-extension "${ext}" --force
      ui_success "${ext}"
    fi
  done < "${SRC_EXTS}"

  log "✓ VS Code extensions installed"
elif [[ -f "${SRC_EXTS}" ]]; then
  log "NOTE: VS Code 'code' CLI not found — skipped extensions. Open VS Code and run 'Shell Command: Install code command in PATH', then re-run setup."
fi

log "✓ Editor configs installed"
