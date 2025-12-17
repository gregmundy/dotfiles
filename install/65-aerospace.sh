#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

echo "==> Installing AeroSpace window manager..."

# AeroSpace is distributed via a Homebrew tap cask
brew_install_cask nikitabobko/tap/aerospace

echo "✓ AeroSpace installed"
echo "NOTE: You must allow Accessibility permissions for AeroSpace:"
echo "      System Settings → Privacy & Security → Accessibility → enable AeroSpace"

