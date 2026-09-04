#!/usr/bin/env bash
set -euo pipefail

xcodes_ensure() {
  brew_ensure
  brew_install_formula xcodes
}

xcodes_install_latest() {
  xcodes install --latest
}

xcodes_select_latest_installed() {
  local latest_app
  local app
  latest_app="$(for app in /Applications/Xcode.app /Applications/Xcode-*.app; do
    if [[ -d "$app" ]]; then printf '%s\n' "$app"; fi
  done | sort -V | tail -n 1)"

  if [[ -z "${latest_app:-}" ]]; then
    echo "ERROR: No Xcode app found in /Applications after install." >&2
    exit 1
  fi

  sudo xcode-select --switch "${latest_app}/Contents/Developer"
  sudo xcodebuild -runFirstLaunch || true
  sudo xcodebuild -license accept || true
}

