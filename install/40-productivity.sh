#!/usr/bin/env bash
# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

brew_ensure
brew_install_cask raycast
brew_install_cask obsidian
brew_install_cask notion

