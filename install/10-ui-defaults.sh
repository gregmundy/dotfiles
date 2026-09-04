#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Applying macOS UI defaults..."

# defaults_write reads the current value first, so re-runs (and dry runs)
# only touch keys that actually differ.
BEFORE="$_UI_COUNT_INSTALLED"

# Dock
defaults_write com.apple.dock tilesize -int 36
defaults_write com.apple.dock magnification -bool true          # hover zoom
defaults_write com.apple.dock largesize -int 54
defaults_write com.apple.dock autohide -bool true
defaults_write com.apple.dock orientation -string bottom
defaults_write com.apple.dock minimize-to-application -bool true
defaults_write com.apple.dock mru-spaces -bool false            # don't reorder Spaces

# Menu bar
defaults_write NSGlobalDomain _HIHideMenuBar -bool true

# Finder
defaults_write com.apple.finder AppleShowAllFiles -bool true
defaults_write NSGlobalDomain AppleShowAllExtensions -bool true
defaults_write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # list view
defaults_write com.apple.finder ShowPathbar -bool true
defaults_write com.apple.finder ShowStatusBar -bool true
defaults_write com.apple.finder FXDefaultSearchScope -string "SCcf"   # search current folder

# Keyboard (log out/in may be required)
defaults_write NSGlobalDomain KeyRepeat -int 1
defaults_write NSGlobalDomain InitialKeyRepeat -int 15

# Trackpad: tap to click, three-finger drag
defaults_write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults_write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults_write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults_write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

if [[ "$_UI_COUNT_INSTALLED" -ne "$BEFORE" ]] || { dry_run && [[ "$_UI_COUNT_PLANNED" -gt 0 ]]; }; then
  log "Restarting UI services..."
  run killall Dock || true
  run killall Finder || true
  run killall SystemUIServer || true
  log "NOTE: If keyboard repeat doesn't feel updated, log out and back in."
fi

log "✓ UI defaults applied"
