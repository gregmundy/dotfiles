#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing Ghostty config..."
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
deploy_file "${REPO_ROOT}/dotfiles/ghostty/config" "${HOME}/.config/ghostty/config"
log "NOTE: Restart Ghostty to apply changes."
