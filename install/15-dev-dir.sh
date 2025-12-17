#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Ensuring ~/Development directory exists..."
ensure_dir "${HOME}/Development"
log "✓ Development directory ready"
