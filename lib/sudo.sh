#!/usr/bin/env bash
set -euo pipefail

# Ask for the sudo password once and keep the credential cache warm for the
# rest of the run, so steps that need root don't each prompt. Shared by
# setup.sh and uninstall.sh.

SUDO_KEEPALIVE_PID=""

sudo_keepalive_start() {
  [[ -t 0 ]] || return 0
  sudo -v
  # Must not inherit set -e: one failed refresh would kill the loop silently.
  (
    set +e
    while true; do
      sudo -n true 2>/dev/null || true
      sleep 50
      kill -0 "$$" 2>/dev/null || exit 0
    done
  ) &
  SUDO_KEEPALIVE_PID=$!
  export SETUP_SUDO_CACHED=1
}

sudo_keepalive_stop() {
  [[ -n "${SUDO_KEEPALIVE_PID}" ]] && kill "${SUDO_KEEPALIVE_PID}" 2>/dev/null
  SUDO_KEEPALIVE_PID=""
  return 0
}
