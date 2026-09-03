#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing git configs..."

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Deploy gitconfig
SRC_CONFIG="${REPO_ROOT}/dotfiles/git/gitconfig"
DEST_CONFIG="${HOME}/.gitconfig"

if [[ ! -f "${SRC_CONFIG}" ]]; then
  log "ERROR: Missing ${SRC_CONFIG}"
  return 1
fi

if [[ -f "${DEST_CONFIG}" ]]; then
  if cmp -s "${SRC_CONFIG}" "${DEST_CONFIG}"; then
    log "✓ gitconfig already up to date"
  else
    TS="$(date +"%Y%m%d-%H%M%S")"
    cp -a "${DEST_CONFIG}" "${DEST_CONFIG}.bak.${TS}"
    log "Backed up existing gitconfig to ${DEST_CONFIG}.bak.${TS}"
    cp -a "${SRC_CONFIG}" "${DEST_CONFIG}"
    log "✓ Installed ${DEST_CONFIG}"
  fi
else
  cp -a "${SRC_CONFIG}" "${DEST_CONFIG}"
  log "✓ Installed ${DEST_CONFIG}"
fi

# Deploy gitignore_global
SRC_IGNORE="${REPO_ROOT}/dotfiles/git/gitignore_global"
DEST_IGNORE="${HOME}/.gitignore_global"

if [[ ! -f "${SRC_IGNORE}" ]]; then
  log "ERROR: Missing ${SRC_IGNORE}"
  return 1
fi

if [[ -f "${DEST_IGNORE}" ]]; then
  if cmp -s "${SRC_IGNORE}" "${DEST_IGNORE}"; then
    log "✓ gitignore_global already up to date"
  else
    TS="$(date +"%Y%m%d-%H%M%S")"
    cp -a "${DEST_IGNORE}" "${DEST_IGNORE}.bak.${TS}"
    log "Backed up existing gitignore_global to ${DEST_IGNORE}.bak.${TS}"
    cp -a "${SRC_IGNORE}" "${DEST_IGNORE}"
    log "✓ Installed ${DEST_IGNORE}"
  fi
else
  cp -a "${SRC_IGNORE}" "${DEST_IGNORE}"
  log "✓ Installed ${DEST_IGNORE}"
fi

# Handle local config (personal details - not in repo)
DEST_LOCAL="${HOME}/.gitconfig.local"

if [[ -f "${DEST_LOCAL}" ]]; then
  log "✓ gitconfig.local already exists"
else
  log "Creating gitconfig.local (personal details)..."

  # Prompt for name
  GIT_NAME="$(ui_input "Full name for git commits:")"
  if [[ -z "${GIT_NAME}" ]]; then
    log "ERROR: Name cannot be empty"
    return 1
  fi

  # Prompt for email
  GIT_EMAIL="$(ui_input "Email for git commits:")"
  if [[ -z "${GIT_EMAIL}" ]]; then
    log "ERROR: Email cannot be empty"
    return 1
  fi

  # Create local config
  cat > "${DEST_LOCAL}" << EOF
# Local git config (not committed to repo)
[user]
    name = ${GIT_NAME}
    email = ${GIT_EMAIL}
EOF

  log "✓ Created ${DEST_LOCAL}"
fi

# Commit signing. gitconfig already points gpg.format=ssh at 1Password's
# op-ssh-sign, but without a signingkey nothing is signed. Ask once; an
# explicit `gpgsign = false` records a skip so re-runs stay quiet.
if git config --file "${DEST_LOCAL}" --get user.signingkey &>/dev/null; then
  log "✓ Commit signing key already configured"
elif git config --file "${DEST_LOCAL}" --get commit.gpgsign &>/dev/null; then
  log "✓ Commit signing explicitly disabled in gitconfig.local"
else
  log "Commit signing uses the 1Password SSH agent (Settings → Developer → SSH Agent)."
  SIGNING_KEY="$(ui_input "SSH public key for commit signing (blank to skip):")"
  if [[ -n "${SIGNING_KEY}" ]]; then
    git config --file "${DEST_LOCAL}" user.signingkey "${SIGNING_KEY}"
    git config --file "${DEST_LOCAL}" commit.gpgsign true
    git config --file "${DEST_LOCAL}" tag.gpgsign true
    log "✓ Enabled SSH commit signing"
  else
    git config --file "${DEST_LOCAL}" commit.gpgsign false
    log "✓ Commit signing skipped (set user.signingkey in ${DEST_LOCAL} to enable later)"
  fi
fi

log "✓ Git configs installed"
