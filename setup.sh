#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cache sudo credentials upfront (some installers need sudo)
echo "Some installers require sudo. You may be prompted for your password."
sudo -v

# Keep sudo alive in the background (refresh every 30s)
while true; do sudo -n true; sleep 30; kill -0 "$$" || exit; done 2>/dev/null &
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
