#!/usr/bin/env bash
set -euo pipefail

ensure_dir() {
  local dir="$1"
  if [[ -d "$dir" ]]; then
    ui_skip "Directory exists: $dir"
  elif [[ "${DRY_RUN:-0}" == "1" ]]; then
    ui_plan "create directory $dir"
  else
    mkdir -p "$dir"
    ui_success "Created directory: $dir"
  fi
}
