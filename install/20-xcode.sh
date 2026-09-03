#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

# Xcode install strategy, in order of preference:
#
#   1. Already present in /Applications  -> just select the newest.
#   2. XCODES_USERNAME + XCODES_PASSWORD  -> `xcodes install --latest`
#      (Apple ID auth; a 2FA code may still be requested by Apple).
#   3. Signed in to the Mac App Store     -> `mas install` (unattended).
#   4. Otherwise                          -> skip with a deferred note.
#
# Nothing later in setup requires full Xcode (Homebrew only needs the Command
# Line Tools), so an unattended run must never block here on an Apple ID or
# an interactive xcodes prompt.

XCODE_MAS_ID=497799835
# Overridable so the no-Xcode branches can be exercised on a machine that has one.
XCODE_APPS_DIR="${XCODE_APPS_DIR:-/Applications}"

# xcodes and mas are installed by the Brewfile (install/05-brewfile.sh).
if ! command -v xcodes &>/dev/null || ! command -v mas &>/dev/null; then
  log "ERROR: xcodes/mas not found — run './setup.sh brewfile' first."
  return 1
fi

find_latest_xcode() {
  # Both a plain Xcode.app (App Store) and versioned Xcode-<ver>.app (xcodes).
  # Glob loop rather than `ls`: with pipefail, a non-matching pattern makes
  # `ls` fail and the whole sourced setup abort silently.
  local app
  for app in "${XCODE_APPS_DIR}"/Xcode.app "${XCODE_APPS_DIR}"/Xcode-*.app; do
    if [[ -d "$app" ]]; then printf '%s\n' "$app"; fi
  done | sort -V | tail -n 1
  return 0
}

XCODE_INSTALLED_NOW=0
LATEST_APP="$(find_latest_xcode)"

if [[ -n "${LATEST_APP}" ]]; then
  log "✓ Xcode already present: ${LATEST_APP}"
elif [[ -n "${XCODES_USERNAME:-}" && -n "${XCODES_PASSWORD:-}" ]]; then
  log "Installing latest Xcode via xcodes (Apple ID from XCODES_USERNAME)..."
  xcodes install --latest --experimental-unxip --no-superuser
  XCODE_INSTALLED_NOW=1
  LATEST_APP="$(find_latest_xcode)"
else
  log "Installing Xcode from the Mac App Store (requires App Store sign-in)..."
  # Do NOT prefix with sudo: mas 7+ elevates the specific steps that need root
  # itself (reusing the sudo credentials setup.sh cached). Running the whole
  # process as root breaks the download/receipt handoff with
  # "Failed to copy receipt ... from /var/folders/...".
  if mas install "${XCODE_MAS_ID}"; then
    XCODE_INSTALLED_NOW=1
    LATEST_APP="$(find_latest_xcode)"
  else
    log "NOTE: Xcode was not installed. Sign in to App Store.app and run './setup.sh xcode', or export XCODES_USERNAME/XCODES_PASSWORD to use xcodes."
  fi
fi

if [[ -z "${LATEST_APP}" ]]; then
  log "✓ Xcode step finished (no Xcode installed; skipping selection)"
  return 0
fi

DEV_DIR="${LATEST_APP}/Contents/Developer"
CURRENT_DEV_DIR="$(xcode-select -p 2>/dev/null || true)"

if [[ "$CURRENT_DEV_DIR" != "$DEV_DIR" ]]; then
  log "Selecting: ${LATEST_APP}"
  sudo xcode-select --switch "$DEV_DIR"
else
  log "✓ Xcode already selected: $DEV_DIR"
fi

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
