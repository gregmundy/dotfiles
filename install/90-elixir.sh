#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing asdf version manager..."
brew_install_formula asdf

# Make `asdf` available in THIS script process (install scripts run in their own process)
ASDF_SH="$(brew --prefix asdf)/libexec/asdf.sh"
if [[ -f "${ASDF_SH}" ]]; then
  # shellcheck source=/dev/null
  . "${ASDF_SH}"
else
  log "ERROR: asdf init script not found at ${ASDF_SH}"
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
    | tail -n 1
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
      | tail -n 1
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
log "   Erlang OTP release: $(erl -eval 'io:format("~s",[erlang:system_info(otp_release)]), halt().' -noshell 2>/dev/null || echo '(not on PATH yet)')"
log "   Elixir: $(elixir -v 2>/dev/null | head -n 1 || echo '(not on PATH yet)')"
