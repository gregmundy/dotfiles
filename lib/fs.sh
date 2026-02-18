#!/usr/bin/env bash
set -euo pipefail

ensure_dir() {
  local dir="$1"
  if [[ -d "$dir" ]]; then
    ui_success "Directory exists: $dir"
  else
    mkdir -p "$dir"
    ui_success "Created directory: $dir"
  fi
}
