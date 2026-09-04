#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing development IDEs and tools..."
brew_install_cask pycharm
brew_install_cask visual-studio-code
brew_install_cask cursor
brew_install_cask cursor-cli

# Claude Code — native installer auto-updates in the background;
# Homebrew cask does not, so we prefer the upstream install script.
if command -v claude >/dev/null 2>&1 || [[ -x "${HOME}/.local/bin/claude" ]]; then
  ui_skip "claude-code"
else
  ui_spin_download "Installing claude-code..." bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
  ui_success "claude-code"
fi

brew_install_formula opencode
log "✓ Development IDEs installed"
