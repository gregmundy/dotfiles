#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing OpenTofu (Terraform-compatible)..."
brew_install_formula opentofu

if command -v tofu &>/dev/null; then
  log "✓ OpenTofu installed: $(tofu version | head -1)"
else
  log "✓ OpenTofu installed (restart terminal to use)"
fi

log "NOTE: OpenTofu is a drop-in replacement for Terraform. Use 'tofu' or the 'terraform' alias."
