#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing 1Password and SSH config..."

# Install 1Password and CLI
brew_install_cask 1password
brew_install_cask 1password-cli

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SSH_DIR="${HOME}/.ssh"
SRC_CONFIG="${REPO_ROOT}/dotfiles/ssh/config"
DEST_CONFIG="${SSH_DIR}/config"

# Ensure .ssh directory exists with correct permissions
if [[ ! -d "${SSH_DIR}" ]]; then
  mkdir -p "${SSH_DIR}"
  chmod 700 "${SSH_DIR}"
  log "✓ Created ${SSH_DIR}"
fi

# Deploy SSH config
if [[ ! -f "${SRC_CONFIG}" ]]; then
  log "ERROR: Missing ${SRC_CONFIG}"
  return 1
fi

if [[ -f "${DEST_CONFIG}" ]]; then
  # Check if 1Password agent is already configured
  if grep -Fq "2BUA8C4S2C.com.1password" "${DEST_CONFIG}"; then
    log "✓ 1Password SSH agent already configured"
  else
    # Append our config to existing file
    log "Appending 1Password agent config to existing SSH config..."
    echo "" >> "${DEST_CONFIG}"
    cat "${SRC_CONFIG}" >> "${DEST_CONFIG}"
    log "✓ Added 1Password agent to SSH config"
  fi
else
  cp -a "${SRC_CONFIG}" "${DEST_CONFIG}"
  chmod 600 "${DEST_CONFIG}"
  log "✓ Installed ${DEST_CONFIG}"
fi

log "✓ SSH config installed"
log "NOTE: Enable SSH agent in 1Password: Settings → Developer → SSH Agent"
