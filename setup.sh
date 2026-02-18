#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/ui.sh"

INSTALL_DIR="${ROOT_DIR}/install"

# Safety: avoid running from random directory
if [[ ! -d "$INSTALL_DIR" ]]; then
  echo "Missing install dir: $INSTALL_DIR" >&2
  exit 1
fi

# Welcome banner
if _have_gum; then
  echo ""
  gum style \
    --bold \
    --foreground 4 \
    --border double \
    --padding "1 3" \
    --align center \
    "macOS Dotfiles Setup" \
    "" \
    "Setting up your development environment"
  echo ""
else
  echo ""
  echo "=== macOS Dotfiles Setup ==="
  echo ""
fi

# Source each installer in order
for f in "$INSTALL_DIR"/*.sh; do
  [[ -f "$f" ]] || continue
  local_name="$(basename "$f")"
  ui_header "${local_name%.sh}"
  # shellcheck source=/dev/null
  source "$f"
done

# Done
echo ""
if _have_gum; then
  gum style \
    --bold \
    --foreground 2 \
    --border rounded \
    --padding "0 3" \
    "✓ Setup complete!"
else
  echo "✓ Setup complete!"
fi
echo ""
