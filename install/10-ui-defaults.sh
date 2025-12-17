#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Applying macOS UI defaults..."

###############################################################################
# Dock
###############################################################################

# Dock size (balanced)
defaults write com.apple.dock tilesize -int 36

# No magnification (consistent muscle memory)
defaults write com.apple.dock magnification -bool false

# Auto-hide Dock + remove delay (feels instant)
defaults write com.apple.dock autohide -bool true

# Dock at the bottom (your preference)
defaults write com.apple.dock orientation -string bottom

# Minimize windows into app icon (keeps Dock tidy)
defaults write com.apple.dock minimize-to-application -bool true

# Faster Mission Control animation
defaults write com.apple.dock expose-animation-duration -float 0.1

# Prevent Spaces from reordering automatically
defaults write com.apple.dock mru-spaces -bool false

###############################################################################
# Menu bar
###############################################################################

# Auto-hide menu bar (more vertical space)
defaults write NSGlobalDomain _HIHideMenuBar -bool true

###############################################################################
# Finder
###############################################################################

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Always show file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool false

# Default Finder view: list
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show path bar + status bar
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Search current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

###############################################################################
# Keyboard
###############################################################################

# Fast key repeat (log out/in may be required)
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15

###############################################################################
# Trackpad
###############################################################################

# Tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Three-finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

###############################################################################
# Apply changes
###############################################################################

log "Restarting UI services..."
killall Dock >/dev/null 2>&1 || true
killall Finder >/dev/null 2>&1 || true
killall SystemUIServer >/dev/null 2>&1 || true

log "✓ UI defaults applied"
log "NOTE: If keyboard repeat doesn't feel updated, log out and back in."
