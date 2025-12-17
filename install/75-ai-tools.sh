#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

echo "==> Installing AI tools..."

###############################################################################
# ChatGPT (OpenAI)
###############################################################################
brew_install_cask chatgpt

###############################################################################
# Claude (Anthropic)
###############################################################################
brew_install_cask claude

echo "✓ AI tools installed"
echo "NOTE: Open ChatGPT and Claude once to sign in."

