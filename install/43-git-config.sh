#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing git configs..."

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

deploy_file "${REPO_ROOT}/dotfiles/git/gitconfig" "${HOME}/.gitconfig"
deploy_file "${REPO_ROOT}/dotfiles/git/gitignore_global" "${HOME}/.gitignore_global"

# Handle local config (personal details - not in repo)
DEST_LOCAL="${HOME}/.gitconfig.local"

if [[ -f "${DEST_LOCAL}" ]]; then
  log "✓ gitconfig.local already exists"
elif dry_run; then
  ui_plan "create ~/.gitconfig.local (prompts for name, email, and optional signing key)"
  return 0
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
  cat > "${DEST_LOCAL}" << EOF  # dry-run: safe (dry run returns above)
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
elif dry_run; then
  ui_plan "ask for an SSH signing key and record the choice in ~/.gitconfig.local"
else
  log "Commit signing uses the 1Password SSH agent (Settings → Developer → SSH Agent)."
  SIGNING_KEY="$(ui_input "SSH public key for commit signing (blank to skip):")"
  if [[ -n "${SIGNING_KEY}" ]]; then
    run git config --file "${DEST_LOCAL}" user.signingkey "${SIGNING_KEY}"
    run git config --file "${DEST_LOCAL}" commit.gpgsign true
    run git config --file "${DEST_LOCAL}" tag.gpgsign true
    log "✓ Enabled SSH commit signing"
  else
    run git config --file "${DEST_LOCAL}" commit.gpgsign false
    log "✓ Commit signing skipped (set user.signingkey in ${DEST_LOCAL} to enable later)"
  fi
fi

log "✓ Git configs installed"
