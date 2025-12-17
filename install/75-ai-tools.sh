#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing AI tools..."

###############################################################################
# ChatGPT (OpenAI)
###############################################################################
brew_install_cask chatgpt

###############################################################################
# Claude (Anthropic)
###############################################################################
brew_install_cask claude

log "✓ AI tools installed"
log "NOTE: Open ChatGPT and Claude once to sign in."
