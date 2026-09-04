#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing networking and VPN tools..."

# Tailscale - mesh VPN. Canonical token is `tailscale-app`; the `tailscale`
# cask is the standalone CLI. This one ships a .pkg, so it prompts for sudo.
brew_install_cask tailscale-app

# ProtonVPN - app bundle, adopted in place if already present
brew_install_cask protonvpn

log "✓ Networking tools installed"
log "NOTE: Tailscale installs via .pkg and prompts for your password. Both apps install network extensions — open each once and approve the system prompt."
