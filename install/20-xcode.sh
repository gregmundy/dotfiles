#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

xcodes_ensure

XCODE_INSTALLED_NOW=0

# If no Xcode app bundles exist, install latest stable.
if ! ls /Applications/Xcode*.app >/dev/null 2>&1; then
  log "No Xcode found in /Applications. Installing latest stable..."
  xcodes install --latest
  XCODE_INSTALLED_NOW=1
else
  log "✓ Xcode already present in /Applications (skipping install)"
fi

# Select newest installed version (by filesystem, not xcodes state)
LATEST_APP="$(ls -1d /Applications/Xcode-*.app 2>/dev/null | sort -V | tail -n 1)"
if [[ -z "${LATEST_APP:-}" ]]; then
  log "ERROR: No Xcode app found after install."
  return 1
fi

DEV_DIR="${LATEST_APP}/Contents/Developer"
CURRENT_DEV_DIR="$(xcode-select -p 2>/dev/null || true)"

if [[ "$CURRENT_DEV_DIR" != "$DEV_DIR" ]]; then
  log "Selecting: ${LATEST_APP}"
  sudo xcode-select --switch "$DEV_DIR"
else
  log "✓ Xcode already selected: $DEV_DIR"
fi

# Only do heavy/privileged first-launch work when we just installed Xcode
if [[ "$XCODE_INSTALLED_NOW" == "1" ]]; then
  log "Running first-launch tasks..."
  sudo xcodebuild -runFirstLaunch || true
  sudo xcodebuild -license accept || true

  log "Downloading iOS platform / simulator runtime..."
  xcodebuild -downloadPlatform iOS || true
else
  log "✓ Skipping first-launch tasks (Xcode was not newly installed)"
fi

log "✓ Xcode installed and configured"
