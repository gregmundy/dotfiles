#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing Starship config..."
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
deploy_file "${REPO_ROOT}/dotfiles/starship/starship.toml" "${HOME}/.config/starship.toml"
log "NOTE: Open a new shell to see the new prompt."
