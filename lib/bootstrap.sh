#!/usr/bin/env bash
set -euo pipefail

# Compute repo root from the currently running installer script (source'd file)
# BASH_SOURCE[0] = this bootstrap.sh
# BASH_SOURCE[1] = the installer script that sourced bootstrap.sh
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[1]}")/.." && pwd)"

# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/brew.sh"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/fs.sh"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/xcodes.sh"

log() { echo "[$(basename "${BASH_SOURCE[1]}")] $*"; }

