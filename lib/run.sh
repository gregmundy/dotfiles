#!/usr/bin/env bash
set -euo pipefail

# Dry-run plumbing. setup.sh exports DRY_RUN=1 for `--dry-run`; every
# side-effecting command in an installer goes through one of these helpers so
# a dry run prints what would change and changes nothing.
#
#   dry_run                    -> true when DRY_RUN=1
#   run <cmd...>               -> run it, or print "would run" in dry-run
#   deploy_file <src> <dest> [mode]
#                              -> copy-with-backup, idempotent via cmp
#   defaults_write <domain> <key> <-bool|-int|-string> <value>
#                              -> idempotent `defaults write`

dry_run() { [[ "${DRY_RUN:-0}" == "1" ]]; }

# "$HOME/x" -> "~/x" for messages. Uses a variable for the tilde because
# bash 3.2 keeps the backslash when the replacement is an escaped tilde.
pretty_path() { local t='~'; printf '%s' "${1/#"$HOME"/$t}"; }

run() {
  if dry_run; then
    ui_plan "run: $*"
    return 0
  fi
  "$@"
}

# Deploy a config file: install if missing, skip if identical, otherwise back
# up the existing file (dest.bak.<timestamp>) and replace it. Parent
# directories are created. Optional third arg sets the mode (e.g. 600).
deploy_file() {
  local src="$1" dest="$2" mode="${3:-}"
  local name
  name="$(pretty_path "$dest")"

  if [[ ! -f "$src" ]]; then
    ui_error "Missing source file: $src"
    return 1
  fi

  if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
    ui_skip "$name already up to date"
    return 0
  fi

  if dry_run; then
    if [[ -f "$dest" ]]; then
      ui_plan "update $name (backup kept)"
    else
      ui_plan "install $name"
    fi
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  if [[ -f "$dest" ]]; then
    local ts
    ts="$(date +"%Y%m%d-%H%M%S")"
    cp -a "$dest" "${dest}.bak.${ts}"
    ui_note "Backed up existing $name to ${name}.bak.${ts}"
  fi
  cp -a "$src" "$dest"
  [[ -n "$mode" ]] && chmod "$mode" "$dest"
  ui_success "Installed $name"
}

# Idempotent `defaults write`. Reads the current value and skips when it
# already matches, so a dry run only lists real changes.
defaults_write() {
  local domain="$1" key="$2" type="$3" value="$4"
  local want current
  case "$type" in
    -bool)   case "$value" in true|TRUE|yes|1) want=1 ;; *) want=0 ;; esac ;;
    -int|-string|-float) want="$value" ;;
    *) ui_error "defaults_write: unsupported type $type"; return 1 ;;
  esac
  current="$(defaults read "$domain" "$key" 2>/dev/null || true)"
  if [[ "$current" == "$want" ]]; then
    ui_skip "$domain $key already $value"
    return 0
  fi
  if dry_run; then
    ui_plan "defaults write $domain $key $type $value (currently: ${current:-unset})"
    return 0
  fi
  defaults write "$domain" "$key" "$type" "$value"
  ui_success "$domain $key = $value"
}

# Append a line to a file unless that exact line is already present.
append_line() {
  local file="$1" line="$2"
  local name; name="$(pretty_path "$file")"
  if [[ -f "$file" ]] && grep -qxF -- "$line" "$file"; then
    ui_skip "$name already contains: $line"
    return 0
  fi
  if dry_run; then
    ui_plan "append to $name: $line"
    return 0
  fi
  mkdir -p "$(dirname "$file")"
  printf '%s\n' "$line" >> "$file"
  ui_success "Appended to $name: $line"
}

# Write a file with the given content unless it already has that content.
write_file() {
  local dest="$1" content="$2"
  local name; name="$(pretty_path "$dest")"
  if [[ -f "$dest" ]] && [[ "$(cat "$dest")" == "$content" ]]; then
    ui_skip "$name already up to date"
    return 0
  fi
  if dry_run; then
    ui_plan "write $name"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  printf '%s\n' "$content" > "$dest"
  ui_success "Wrote $name"
}
