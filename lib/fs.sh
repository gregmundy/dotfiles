#!/usr/bin/env bash
set -euo pipefail

ensure_dir() {
  local dir="$1"
  if [[ -d "$dir" ]]; then
    echo "✓ Directory exists: $dir"
  else
    mkdir -p "$dir"
    echo "Created directory: $dir"
  fi
}

