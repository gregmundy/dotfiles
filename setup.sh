#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/ui.sh"

INSTALL_DIR="${ROOT_DIR}/install"

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
ui_progress_init "${#SCRIPTS[@]}"

# Source each installer in order
for f in "${SCRIPTS[@]}"; do
  local_name="$(basename "$f" .sh)"
  # Strip numeric prefix for cleaner display (e.g., "05-misc-deps" → "misc-deps")
  display_name="${local_name#[0-9][0-9]-}"
  ui_header "$display_name"
  # shellcheck source=/dev/null
  source "$f"
done

ui_show_notes

ELAPSED="$(( SECONDS - START_TIME ))"
ui_complete "$ELAPSED"
