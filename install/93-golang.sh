#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing Go..."
brew_install_formula go

# GoReleaser - build/release automation for Go projects
brew_install_formula goreleaser

# Check if go is available (might need PATH update on first install)
if ! command -v go &>/dev/null; then
  log "✓ Go installed (restart terminal to use)"
  log "NOTE: Go toolchain binaries (gopls, staticcheck) were skipped — re-run this installer after restarting your terminal."
  return 0
fi

log "✓ Go installed: $(go version)"

# Go-native tooling installed via `go install` rather than brew, so versions
# track the Go toolchain. Binaries land in $GOBIN (default $GOPATH/bin), which
# dotfiles/zsh/path.zsh already adds to PATH.
GO_BIN_DIR="$(go env GOBIN)"
[[ -z "${GO_BIN_DIR}" ]] && GO_BIN_DIR="$(go env GOPATH)/bin"

install_go_tool() {
  local bin="$1" pkg="$2"
  if [[ -x "${GO_BIN_DIR}/${bin}" ]]; then
    ui_skip "${bin}"
  else
    ui_spin "Installing ${bin}..." go install "${pkg}"
    ui_success "${bin}"
  fi
}

log "Installing Go tooling..."
install_go_tool gopls       golang.org/x/tools/gopls@latest
install_go_tool staticcheck honnef.co/go/tools/cmd/staticcheck@latest

log "✓ Go tooling installed (${GO_BIN_DIR})"
