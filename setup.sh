#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/ui.sh"

INSTALL_DIR="${ROOT_DIR}/install"

# Homebrew behaviour for the whole run. Installers are sourced, so these apply
# to every brew call. 00-homebrew.sh performs the single `brew update`.
export HOMEBREW_NO_ASK=1           # Homebrew 6 "ask mode" prompts before installing deps; run unattended
export HOMEBREW_NO_AUTO_UPDATE=1   # don't re-run `brew update` before each install
export HOMEBREW_NO_ENV_HINTS=1     # quieter output
export HOMEBREW_NO_INSTALL_CLEANUP=1  # skip per-install cleanup passes; run `brew cleanup` yourself

usage() {
  cat <<'USAGE'
Usage: ./setup.sh [options] [filter ...]

Runs every installer in install/ in numeric order. With one or more filters,
runs only installers whose file name contains a filter (e.g. "91", "node",
"zsh"), still in numeric order.

Options:
  -l, --list             List installers (with the filters applied) and exit
  -c, --clean-backups    Remove *.bak.<timestamp> files left by earlier runs
  -h, --help             Show this help
USAGE
}

# Locations installers write timestamped backups to (see cp -a "$DEST" "$DEST.bak.$TS").
backup_dirs() {
  printf '%s\n' \
    "${HOME}" \
    "${HOME}/.config" \
    "${HOME}/.config/ghostty" \
    "${HOME}/.config/nvim" \
    "${HOME}/.claude" \
    "${HOME}/.ssh" \
    "${HOME}/Library/Application Support/Code/User"
}

clean_backups() {
  local files=()
  local dir
  while IFS= read -r dir; do
    [[ -d "$dir" ]] || continue
    while IFS= read -r f; do
      files+=("$f")
    done < <(find "$dir" -maxdepth 1 -type f -name '*.bak.[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9]' 2>/dev/null | sort)
  done < <(backup_dirs)

  if [[ ${#files[@]} -eq 0 ]]; then
    ui_skip "No setup backups found"
    return 0
  fi

  ui_step "Setup backups found:"
  printf '    %s\n' "${files[@]}"
  if ui_confirm "Delete ${#files[@]} file(s)?"; then
    rm -f -- "${files[@]}"
    ui_success "Removed ${#files[@]} backup file(s)"
  else
    ui_skip "Kept backups"
  fi
}

LIST_ONLY=0
FILTERS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    -l|--list) LIST_ONLY=1 ;;
    -c|--clean-backups) clean_backups; exit 0 ;;
    -*) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    *) FILTERS+=("$1") ;;
  esac
  shift
done

# Safety: avoid running from random directory
if [[ ! -d "$INSTALL_DIR" ]]; then
  echo "Missing install dir: $INSTALL_DIR" >&2
  exit 1
fi

# Select installers: all of them, or only those matching a filter.
matches_filter() {
  local name="$1" f
  [[ ${#FILTERS[@]} -eq 0 ]] && return 0
  for f in "${FILTERS[@]}"; do
    [[ "$name" == *"$f"* ]] && return 0
  done
  return 1
}

SCRIPTS=()
for f in "$INSTALL_DIR"/*.sh; do
  [[ -f "$f" ]] || continue
  matches_filter "$(basename "$f" .sh)" && SCRIPTS+=("$f")
done

if [[ ${#SCRIPTS[@]} -eq 0 ]]; then
  echo "No installers match: ${FILTERS[*]}" >&2
  exit 1
fi

if [[ "$LIST_ONLY" == "1" ]]; then
  for f in "${SCRIPTS[@]}"; do basename "$f" .sh; done
  exit 0
fi

START_TIME="$SECONDS"

ui_welcome

# Ask for the sudo password once, up front, and keep the credential cache warm
# for the whole run. Several steps need root (xcode-select, mas install, .pkg
# casks such as Tailscale); without this they each prompt mid-run and an
# unattended session stalls on whichever one comes first.
SUDO_KEEPALIVE_PID=""
if [[ -t 0 ]]; then
  ui_step "Setup needs administrator rights for a few steps (xcode-select, mas, .pkg casks)."
  sudo -v
  # The refresher must not inherit set -e: a single failed `sudo -n` (e.g.
  # right after something invalidates the ticket) would kill it silently and
  # every later root step would prompt again.
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
fi

# Installers are sourced under set -e, so any unhandled failure ends the whole
# run. Report which installer and command did it instead of exiting silently.
# (An EXIT trap, not ERR: ERR traps with errtrace also fire inside $(...)
# substitutions and would pollute captured values.)
CURRENT_INSTALLER=""
SETUP_DONE=0
FAILED_CMD=""
# Without errtrace this ERR trap only fires at the top level of setup.sh and
# of the sourced installer, never inside functions or $(...) — so it can
# safely record the command without printing anything.
trap 'FAILED_CMD="${BASH_COMMAND}"' ERR
on_exit() {
  local rc=$?
  local failed_cmd="${FAILED_CMD:-${BASH_COMMAND}}"
  [[ -n "${SUDO_KEEPALIVE_PID}" ]] && kill "${SUDO_KEEPALIVE_PID}" 2>/dev/null
  if [[ "$rc" -ne 0 && "$SETUP_DONE" -eq 0 && -n "$CURRENT_INSTALLER" ]]; then
    ui_error "Setup aborted in ${CURRENT_INSTALLER}: \"${failed_cmd}\" failed (exit ${rc})"
  fi
}
trap on_exit EXIT
ui_progress_init "${#SCRIPTS[@]}"

# Source each installer in order
for f in "${SCRIPTS[@]}"; do
  local_name="$(basename "$f" .sh)"
  CURRENT_INSTALLER="$local_name"
  # Strip numeric prefix for cleaner display (e.g., "05-misc-deps" → "misc-deps")
  display_name="${local_name#[0-9][0-9]-}"
  ui_header "$display_name"
  # shellcheck source=/dev/null
  source "$f"
done

CURRENT_INSTALLER=""
SETUP_DONE=1
ui_show_notes

ELAPSED="$(( SECONDS - START_TIME ))"
ui_complete "$ELAPSED"
