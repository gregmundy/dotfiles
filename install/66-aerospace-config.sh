#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

echo "==> Installing AeroSpace config..."

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${REPO_ROOT}/dotfiles/aerospace/aerospace.toml"
DEST="${HOME}/.aerospace.toml"

if [[ ! -f "${SRC}" ]]; then
  echo "ERROR: Missing ${SRC}" >&2
  return 1
fi

# Backup existing config if it exists and differs
if [[ -f "${DEST}" ]]; then
  if cmp -s "${SRC}" "${DEST}"; then
    echo "✓ AeroSpace config already up to date: ${DEST}"
    return 0
  fi
  TS="$(date +"%Y%m%d-%H%M%S")"
  cp -a "${DEST}" "${DEST}.bak.${TS}"
  echo "Backed up existing config to ${DEST}.bak.${TS}"
fi

cp -a "${SRC}" "${DEST}"
echo "✓ Installed ${DEST}"

echo "NOTE: If AeroSpace is running, reload config (AeroSpace menu → Reload Config)."

