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

###############################################################################
# LM Studio - GUI for running local LLMs
###############################################################################
brew_install_cask lm-studio

###############################################################################
# Ollama - local LLM runtime / API (menu-bar app auto-starts the daemon)
###############################################################################
brew_install_cask ollama-app

log "✓ AI tools installed"
log "NOTE: Open ChatGPT, Claude, Ollama, and LM Studio once to sign in / start daemons."
