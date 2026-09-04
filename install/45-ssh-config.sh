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

ensure_dir "${SSH_DIR}"
if [[ -d "${SSH_DIR}" && "$(stat -f '%Lp' "${SSH_DIR}")" != "700" ]]; then
  run chmod 700 "${SSH_DIR}"
fi

if [[ ! -f "${SRC_CONFIG}" ]]; then
  log "ERROR: Missing ${SRC_CONFIG}"
  return 1
fi

append_ssh_config() {
  printf '\n' >> "${DEST_CONFIG}"  # dry-run: safe (called via run)
  cat "${SRC_CONFIG}" >> "${DEST_CONFIG}"  # dry-run: safe (called via run)
}

if [[ -f "${DEST_CONFIG}" ]]; then
  # Existing config: add the 1Password agent block rather than replacing it.
  if grep -Fq "2BUA8C4S2C.com.1password" "${DEST_CONFIG}"; then
    log "✓ 1Password SSH agent already configured"
  else
    log "Appending 1Password agent config to existing SSH config..."
    run append_ssh_config
    log "✓ Added 1Password agent to SSH config"
  fi
else
  deploy_file "${SRC_CONFIG}" "${DEST_CONFIG}" 600
fi

log "✓ SSH config installed"

log "NOTE: 1Password SSH agent: Open 1Password → Settings → Developer → Enable 'Use the SSH Agent' and 'Integrate with 1Password CLI'"
