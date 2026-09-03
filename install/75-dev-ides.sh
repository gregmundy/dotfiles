#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

# IDEs (VS Code, Cursor, PyCharm) and opencode come from the Brewfile.
# Claude Code ships its own installer, so it lives here.
log "Installing Claude Code..."

if command -v claude >/dev/null 2>&1 || [[ -x "${HOME}/.local/bin/claude" ]]; then
  log "✓ claude-code already installed"
else
  ui_spin_download "Installing claude-code..." bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
  log "✓ claude-code installed"
fi
