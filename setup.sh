#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${ROOT_DIR}/install"

# Safety: avoid running from random directory
if [[ ! -d "$INSTALL_DIR" ]]; then
  echo "Missing install dir: $INSTALL_DIR" >&2
  exit 1
fi

# Source each installer in order
for f in "$INSTALL_DIR"/*.sh; do
  [[ -f "$f" ]] || continue
  echo "==> Running: $(basename "$f")"
  # shellcheck source=/dev/null
  source "$f"
done

echo "✅ Done."
