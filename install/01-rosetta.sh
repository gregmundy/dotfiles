#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

# Only needed on Apple Silicon
if [[ "$(uname -m)" != "arm64" ]]; then
  log "✓ Rosetta 2 not needed (Intel Mac)"
  return 0
fi

if arch -x86_64 /usr/bin/true 2>/dev/null; then
  log "✓ Rosetta 2 already installed"
else
  log "Installing Rosetta 2..."
  softwareupdate --install-rosetta --agree-to-license
  log "✓ Rosetta 2 installed"
fi
