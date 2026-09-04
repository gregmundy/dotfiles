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
mas_install_app() {
  local id="$1" name="$2"
  if [[ -d "/Applications/${name}.app" ]]; then
    log "✓ ${name} already installed"
  elif run mas install "${id}"; then
    log "✓ ${name} installed"
  else
    log "NOTE: ${name} was not installed — sign in to App Store.app and run './setup.sh apple-dev'."
  fi
}

# Second argument is the .app bundle name in /Applications.
mas_install_app 640199958 "Developer"
mas_install_app 899247664 "TestFlight"

log "✓ Apple developer tools installed"
