#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing mobile development tools..."

# Watchman - file watcher required by React Native's Metro bundler
brew_install_formula watchman

# CocoaPods - iOS dependency manager
brew_install_formula cocoapods

log "✓ Mobile development tools installed"
log ""
log "NOTE: Expo/EAS CLI are managed via Node (eas-cli in default-packages)."
log "      Use 'npx expo' to run Expo commands (no global install needed)."
