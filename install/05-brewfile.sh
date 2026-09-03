#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

# Installs everything declared in the repo Brewfile: taps (trusted), formulae,
# casks (--adopt), Mac App Store apps, VS Code extensions, and Go tools.
# Homebrew Bundle owns the idempotency and keeps pace with Homebrew's own
# behaviour changes (ask mode, tap trust, mas without sudo), which is why the
# per-package installers were folded into it.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREWFILE="${REPO_ROOT}/Brewfile"

if [[ ! -f "${BREWFILE}" ]]; then
  log "ERROR: Missing ${BREWFILE}"
  return 1
fi

log "Applying Brewfile (${BREWFILE})..."

# --no-upgrade: setup installs what's missing; it does not upgrade the machine.
# Run `brew upgrade` / `brew bundle install --file Brewfile` yourself for that.
# Bundle keeps going after an individual failure and exits non-zero at the end,
# so report rather than abort — a typical cause is App Store apps when
# App Store.app isn't signed in.
if brew bundle install --file "${BREWFILE}" --no-upgrade; then
  log "✓ Brewfile applied"
else
  log "ERROR: Some Brewfile entries failed to install (see output above)."
  log "NOTE: Re-run './setup.sh brewfile' after fixing the cause (e.g. sign in to App Store.app)."
fi

# Post-install pointers for things that need a human once.
log "NOTE: ngrok needs an authtoken before first use: ngrok config add-authtoken <token>"
log "NOTE: Tailscale and ProtonVPN install network extensions — open each once and approve the system prompt."
log "NOTE: Rectangle: grant Accessibility permission when prompted on first launch."
log "NOTE: Open ChatGPT, Codex, Claude, Ollama, and LM Studio once to sign in / start daemons."
log "NOTE: Autodesk Fusion self-updates into ~/Applications and needs an Autodesk sign-in on first launch."
