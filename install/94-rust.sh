#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing Rust via rustup..."
brew_install_formula rustup

RUSTUP="$(brew --prefix rustup)/bin/rustup"

if [[ ! -x "${RUSTUP}" ]]; then
  log "ERROR: rustup not found at ${RUSTUP}"
  return 1
fi

# Check if Rust toolchain is already installed
if [[ -d "${HOME}/.rustup/toolchains" ]] && ls "${HOME}/.rustup/toolchains" | grep -q stable; then
  log "✓ Rust stable toolchain already installed"
else
  run "${RUSTUP}" default stable
  log "✓ Rust stable toolchain installed"
fi

# Verify
if [[ -x "${HOME}/.cargo/bin/rustc" ]]; then
  log "✓ Rust installed: $("${HOME}/.cargo/bin/rustc" --version)"
else
  log "✓ Rust installed (restart terminal to use)"
fi
