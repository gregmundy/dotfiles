#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

brew_install_cask pycharm
brew_install_cask visual-studio-code
brew_install_cask cursor
brew_install_cask cursor-cli
