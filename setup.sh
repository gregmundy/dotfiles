#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/ui.sh"

INSTALL_DIR="${ROOT_DIR}/install"

# Safety: avoid running from random directory
if [[ ! -d "$INSTALL_DIR" ]]; then
  echo "Missing install dir: $INSTALL_DIR" >&2
  exit 1
fi

# Count scripts for progress tracking
SCRIPT_COUNT=0
for f in "$INSTALL_DIR"/*.sh; do
  [[ -f "$f" ]] && (( SCRIPT_COUNT++ ))
done

START_TIME="$SECONDS"

ui_welcome
ui_progress_init "$SCRIPT_COUNT"

# Source each installer in order
for f in "$INSTALL_DIR"/*.sh; do
  [[ -f "$f" ]] || continue
  local_name="$(basename "$f" .sh)"
  # Strip numeric prefix for cleaner display (e.g., "05-misc-deps" → "misc-deps")
  display_name="${local_name#[0-9][0-9]-}"
  ui_header "$display_name"
  # shellcheck source=/dev/null
  source "$f"
done

ELAPSED="$(( SECONDS - START_TIME ))"
ui_complete "$ELAPSED"
