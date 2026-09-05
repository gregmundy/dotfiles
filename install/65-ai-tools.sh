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
# Codex (OpenAI desktop app for managing coding agents)
#
# Cask token is `codex-app`, NOT `codex` — the `codex` cask is the terminal
# CLI, which install/75-dev-ides.sh installs via OpenAI's own standalone
# installer instead. Installing both would be redundant.
#
# WARNING: codex-app is deprecated in Homebrew (discontinued upstream) and is
# scheduled to be disabled on 2027-07-12. Kept for parity with the current
# machine; drop this line once the desktop app is retired.
###############################################################################
brew_install_cask codex-app

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

###############################################################################
# llamavm  - nvm-style version manager for source-built llama.cpp
# llamactl - supervisor / model manager for llama.cpp servers
###############################################################################
brew_tap_trusted gregmundy/tap
brew_install_cask llamavm
brew_install_cask llamactl

log "✓ AI tools installed"
log "NOTE: Open ChatGPT, Codex, Claude, Ollama, and LM Studio once to sign in / start daemons."
