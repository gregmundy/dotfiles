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
# Parses prefixes to pick the right style:
#   ✓ ... already ...  → dimmed (skipped)
#   ✓ ...              → green success
#   ERROR: ...         → red error
#   NOTE: ...          → dimmed note
#   (anything else)    → step in progress
log() {
  local msg="$*"
  case "$msg" in
    "✓ "*already*|"✓ "*"already"*|"✓ "*"up to date"*|"✓ "*"not needed"*)
      ui_skip "${msg#✓ }" ;;
    "✓ "*)
      ui_success "${msg#✓ }" ;;
    "ERROR:"*)
      ui_error "${msg#ERROR: }" ;;
    "NOTE:"*)
      ui_defer_note "${msg#NOTE: }" ;;
    "")
      echo "" ;;
    *)
      ui_step "$msg" ;;
  esac
}
