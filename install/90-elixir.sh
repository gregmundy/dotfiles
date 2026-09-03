#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

# asdf itself comes from the Brewfile (v0.16+ is a Go binary — nothing to source).
if ! command -v asdf >/dev/null 2>&1; then
  log "ERROR: asdf not found — run './setup.sh brewfile' first."
  return 1
fi

log "Ensuring asdf plugins (erlang, elixir)..."
if asdf plugin list | grep -Fxq "erlang"; then
  log "✓ asdf plugin already installed: erlang"
else
  asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
  log "✓ Installed asdf plugin: erlang"
fi

if asdf plugin list | grep -Fxq "elixir"; then
  log "✓ asdf plugin already installed: elixir"
else
  asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git
  log "✓ Installed asdf plugin: elixir"
fi

log "Updating asdf plugin indexes..."
asdf plugin update erlang
asdf plugin update elixir

log "Resolving latest stable Erlang..."
LATEST_ERLANG="$(
  asdf list all erlang \
    | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
    | tail -n 1 || true
)"

if [[ -z "${LATEST_ERLANG:-}" ]]; then
  log "ERROR: Could not determine latest stable Erlang version."
  return 1
fi

log "Resolving latest stable Elixir matching OTP major..."
ERLANG_MAJOR="${LATEST_ERLANG%%.*}"

# Prefer Elixir builds that explicitly match OTP major: e.g. 1.17.3-otp-27
LATEST_ELIXIR="$(
  asdf list all elixir \
    | grep -E "^[0-9]+\.[0-9]+\.[0-9]+-otp-${ERLANG_MAJOR}$" \
    | tail -n 1 || true
)"

# Fallback if the plugin doesn't expose otp-suffixed variants
if [[ -z "${LATEST_ELIXIR:-}" ]]; then
  LATEST_ELIXIR="$(
    asdf list all elixir \
      | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
      | tail -n 1 || true
  )"
fi

if [[ -z "${LATEST_ELIXIR:-}" ]]; then
  log "ERROR: Could not determine latest stable Elixir version."
  return 1
fi

log "✓ Latest stable Erlang: ${LATEST_ERLANG}"
log "✓ Latest stable Elixir: ${LATEST_ELIXIR}"

log "Installing Erlang (if needed)..."
if asdf list erlang 2>/dev/null | grep -Fq "${LATEST_ERLANG}"; then
  log "✓ Erlang already installed: ${LATEST_ERLANG}"
else
  asdf install erlang "${LATEST_ERLANG}"
fi

log "Installing Elixir (if needed)..."
if asdf list elixir 2>/dev/null | grep -Fq "${LATEST_ELIXIR}"; then
  log "✓ Elixir already installed: ${LATEST_ELIXIR}"
else
  asdf install elixir "${LATEST_ELIXIR}"
fi

log "Setting global defaults..."
asdf set -u erlang "${LATEST_ERLANG}"
asdf set -u elixir "${LATEST_ELIXIR}"

log "Reshimming..."
asdf reshim erlang
asdf reshim elixir

log "✓ Erlang/Elixir installed and configured"
log "   Erlang: ${LATEST_ERLANG}"
log "   Elixir: ${LATEST_ELIXIR}"
