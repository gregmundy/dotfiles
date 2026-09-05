#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing Apple developer tools from App Store..."

if ! command -v mas &>/dev/null; then
  log "ERROR: mas not installed. Run 25-mas.sh first."
  return 1
fi

# mas 7+ requests root for the steps that need it, reusing the sudo credentials
# setup.sh cached at start. Never run it under sudo: as root the App Store
# download lands in root's temp dir and the receipt copy fails with
# "Failed to copy receipt for <app> from '/var/folders/...'".
# Overridable so the health check can be exercised against a temp dir.
APPS_DIR="${APPS_DIR:-/Applications}"

# A correct App Store install has an _MASReceipt and a valid signature. A
# bundle missing either (e.g. left behind by an interrupted or root-run mas
# install) may not launch or update, so treat it as not installed and let
# mas reinstall over it.
app_healthy() {
  local app="${APPS_DIR}/$1.app"
  [[ -d "$app" && -f "$app/Contents/_MASReceipt/receipt" ]] || return 1
  codesign --verify --deep --strict "$app" >/dev/null 2>&1
}

mas_install_app() {
  local id="$1" name="$2"
  if app_healthy "$name"; then
    log "✓ ${name} already installed"
    return 0
  fi
  if [[ -d "${APPS_DIR}/${name}.app" ]]; then
    log "${name} is present but incomplete (missing App Store receipt or bad signature) — reinstalling..."
  fi
  if run mas install "${id}"; then
    if dry_run || app_healthy "$name"; then
      log "✓ ${name} installed"
    else
      log "ERROR: ${name} still fails verification after install"
      log "NOTE: ${name}: open App Store.app, sign in, and reinstall it from your Purchased list."
    fi
  else
    log "NOTE: ${name} was not installed — sign in to App Store.app and run './setup.sh apple-dev'."
  fi
}

# Second argument is the .app bundle name in /Applications.
mas_install_app 640199958 "Developer"
mas_install_app 899247664 "TestFlight"

log "✓ Apple developer tools installed"
