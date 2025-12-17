#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing zsh customizations..."

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSH_CUSTOM_DIR="${REPO_ROOT}/dotfiles/zsh"
ZSHRC="${HOME}/.zshrc"

if [[ ! -d "${ZSH_CUSTOM_DIR}" ]]; then
  log "ERROR: Missing ${ZSH_CUSTOM_DIR}"
  return 1
fi

if [[ ! -f "${ZSHRC}" ]]; then
  log "ERROR: ${ZSHRC} not found. Install Oh My Zsh first."
  return 1
fi

# Source line to add to .zshrc
SOURCE_BLOCK="# Custom aliases and functions
for file in ${ZSH_CUSTOM_DIR}/*.zsh; do
  [[ -f \"\$file\" ]] && source \"\$file\"
done"

# Check if already sourced
if grep -Fq "dotfiles/zsh" "${ZSHRC}"; then
  log "✓ Zsh customizations already sourced in ${ZSHRC}"
  return 0
fi

# Add source block to end of .zshrc
{
  echo ""
  echo "${SOURCE_BLOCK}"
} >> "${ZSHRC}"

log "✓ Added custom zsh sources to ${ZSHRC}"
log "NOTE: Run 'source ~/.zshrc' or restart your terminal."
