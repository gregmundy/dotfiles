#!/usr/bin/env bash
set -euo pipefail

# Compute repo root from the currently running installer script (source'd file)
# BASH_SOURCE[0] = this bootstrap.sh
# BASH_SOURCE[1] = the installer script that sourced bootstrap.sh
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[1]}")/.." && pwd)"

# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/ui.sh"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/brew.sh"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/fs.sh"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/xcodes.sh"

# Route log() through ui helpers.
# Parses prefixes (✓, ERROR:, NOTE:) to pick the right style.
log() {
  local msg="$*"
  case "$msg" in
    "✓ "*)   ui_success "${msg#✓ }" ;;
    "ERROR:"*) ui_error "${msg#ERROR: }" ;;
    "NOTE:"*)  ui_note "${msg#NOTE: }" ;;
    "")        echo "" ;;
    *)         ui_step "$msg" ;;
  esac
}
