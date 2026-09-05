#!/usr/bin/env bash
#
# Undo what setup.sh did. DRY RUN BY DEFAULT: prints the plan and changes
# nothing. Pass --apply to execute (you will be asked to type "uninstall").
#
# What it will never touch: ~/Development, SSH keys, Claude Code sessions
# (~/.claude/projects), Documents/Desktop/etc., 1Password data.
# Config files are moved into ~/.dotfiles-uninstall-<timestamp>/ rather than
# deleted, so identity files and hand edits stay recoverable.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/ui.sh"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/sudo.sh"
# shellcheck source=/dev/null
source "${ROOT_DIR}/lib/run.sh"

usage() {
  cat <<'USAGE'
Usage: ./uninstall.sh [--apply] [tier ...]

Dry run by default. Prints everything it would remove; nothing changes.

  --apply          Actually do it (asks you to type "uninstall" first)

Tiers (none given = all of them, in this order):
  --configs        Deployed dotfiles, Oh My Zsh, VS Code extensions, Claude Code
                   binary, Docker login item, setup backups  (moved to a trash dir)
  --runtimes       nvm, asdf, rustup/cargo, uv Pythons, Go workspace, llamavm
  --apps           Every cask setup installs (zapped), App Store apps, Xcode
  --packages       Every formula setup installs, taps, brew autoremove
  --defaults       macOS defaults set by setup (reverts to system defaults)
  --homebrew       Homebrew itself and the Command Line Tools

  -h, --help
USAGE
}

APPLY=0
TIERS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --apply) APPLY=1 ;;
    --configs|--runtimes|--apps|--packages|--defaults|--homebrew) TIERS+=("${1#--}") ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done
[[ ${#TIERS[@]} -eq 0 ]] && TIERS=(configs runtimes apps packages defaults homebrew)

export DRY_RUN=1
[[ "$APPLY" == "1" ]] && DRY_RUN=0

# Keep Homebrew quiet and non-interactive for the whole run.
export HOMEBREW_NO_ASK=1 HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ENV_HINTS=1

tier_selected() { local t; for t in "${TIERS[@]}"; do [[ "$t" == "$1" ]] && return 0; done; return 1; }

TRASH="${HOME}/.dotfiles-uninstall-$(date +"%Y%m%d-%H%M%S")"

# ── Helpers ──────────────────────────────────────────────────────────

# Move a file or directory into the trash dir, preserving its path under $HOME.
trash_path() {
  local path="$1"
  [[ -e "$path" ]] || return 0
  local name; name="$(pretty_path "$path")"
  if dry_run; then
    ui_plan "move $name to $(pretty_path "$TRASH")/"
    return 0
  fi
  local rel="${path#"$HOME"/}"
  mkdir -p "${TRASH}/$(dirname "$rel")"  # dry-run: safe (guarded above)
  mv "$path" "${TRASH}/${rel}"  # dry-run: safe (guarded above)
  ui_success "Moved $name to trash dir"
}

# Trash a deployed config only if it still matches the repo copy; a hand-edited
# file is left alone with a note rather than silently removed.
trash_if_matches() {
  local path="$1" repo_src="$2"
  [[ -e "$path" ]] || return 0
  if cmp -s "$path" "$repo_src"; then
    trash_path "$path"
  else
    ui_note "Left $(pretty_path "$path") in place: it differs from the repo copy (hand-edited?)"
  fi
}

# Delete a regenerable tree outright (rm -rf), only ever under $HOME.
remove_tree() {
  local path="$1"
  [[ -e "$path" ]] || return 0
  case "$path" in "$HOME"/?*) ;; *) ui_error "refusing to remove outside HOME: $path"; return 1 ;; esac
  local name; name="$(pretty_path "$path")"
  if dry_run; then
    ui_plan "delete $name"
    return 0
  fi
  chmod -R u+w "$path" 2>/dev/null || true  # dry-run: safe (guarded above)
  rm -rf "$path"  # dry-run: safe (guarded above)
  ui_success "Deleted $name"
}

# Lists derived from the installers so this can't drift from setup.sh.
# (while-read loops rather than mapfile: macOS ships bash 3.2.)
FORMULAE=(); CASKS=(); TAPS=(); MAS_IDS=(); DEFAULT_KEYS=()
while IFS= read -r x; do FORMULAE+=("$x"); done < <(grep -hoE 'brew_install_formula[[:space:]]+[^[:space:]#]+' "${ROOT_DIR}"/install/*.sh "${ROOT_DIR}"/lib/*.sh | awk '{print $2}' | sort -u)
while IFS= read -r x; do CASKS+=("$x");    done < <(grep -hoE 'brew_install_cask[[:space:]]+[^[:space:]#]+'    "${ROOT_DIR}"/install/*.sh | awk '{print $2}' | sort -u)
while IFS= read -r x; do TAPS+=("$x");     done < <(grep -hoE 'brew_tap_trusted[[:space:]]+[^[:space:]#]+'     "${ROOT_DIR}"/install/*.sh | awk '{print $2}' | sort -u)
while IFS= read -r x; do MAS_IDS+=("$x");  done < <(grep -hoE 'mas_install_app[[:space:]]+[0-9]+'             "${ROOT_DIR}"/install/26-apple-dev.sh | awk '{print $2}' | sort -u)
while IFS= read -r x; do DEFAULT_KEYS+=("$x"); done < <(grep -hE '^defaults_write[[:space:]]' "${ROOT_DIR}"/install/10-ui-defaults.sh | awk '{print $2 " " $3}')

have_brew() { command -v brew >/dev/null 2>&1; }

# ── Tiers ────────────────────────────────────────────────────────────

tier_configs() {
  ui_header "configs"
  local D="${ROOT_DIR}/dotfiles"

  # (git-lfs filters live in ~/.gitconfig, which is trashed below; nothing else to undo.)

  # Deployed dotfiles. Exact copies of the repo are trashed; edited ones stay.
  trash_if_matches "${HOME}/.editorconfig"            "${D}/editorconfig"
  trash_if_matches "${HOME}/.vimrc"                   "${D}/vim/vimrc"
  trash_if_matches "${HOME}/.config/nvim/init.lua"    "${D}/nvim/init.lua"
  trash_if_matches "${HOME}/.config/ghostty/config"   "${D}/ghostty/config"
  trash_if_matches "${HOME}/.tmux.conf"               "${D}/tmux/tmux.conf"
  trash_if_matches "${HOME}/.config/starship.toml"    "${D}/starship/starship.toml"
  trash_if_matches "${HOME}/.gitconfig"               "${D}/git/gitconfig"
  trash_if_matches "${HOME}/.gitignore_global"        "${D}/git/gitignore_global"
  trash_if_matches "${HOME}/.ssh/config"              "${D}/ssh/config"
  trash_if_matches "${HOME}/Library/Application Support/Code/User/settings.json"    "${D}/vscode/settings.json"
  trash_if_matches "${HOME}/Library/Application Support/Code/User/keybindings.json" "${D}/vscode/keybindings.json"

  # Files setup generated or merged (never identical to a repo file).
  trash_path "${HOME}/.gitconfig.local"
  trash_path "${HOME}/.claude/settings.json"
  trash_path "${HOME}/.zshrc"

  # Oh My Zsh (includes the custom loader and cloned plugins).
  remove_tree "${HOME}/.oh-my-zsh"

  # VS Code extensions setup installed.
  if [[ -f "${D}/vscode/extensions.txt" ]] && command -v code >/dev/null 2>&1; then
    local ext
    while IFS= read -r ext || [[ -n "$ext" ]]; do
      ext="${ext%%#*}"; ext="$(echo "$ext" | xargs || true)"; [[ -z "$ext" ]] && continue
      if code --list-extensions 2>/dev/null | grep -qix "$ext"; then
        run code --uninstall-extension "$ext" >/dev/null
      fi
    done < "${D}/vscode/extensions.txt"
  fi

  # Claude Code (its own installer, not Homebrew). Sessions in ~/.claude stay.
  remove_tree "${HOME}/.local/bin/claude"
  remove_tree "${HOME}/.local/share/claude"

  # Docker login item.
  if osascript -e 'tell application "System Events" to get name of every login item' 2>/dev/null | grep -qw Docker; then
    remove_docker_login_item() { osascript -e 'tell application "System Events" to delete login item "Docker"' >/dev/null; }  # dry-run: safe (called via run)
    run remove_docker_login_item
  fi

  # Backups left by earlier setup runs.
  local dir f
  for dir in "${HOME}" "${HOME}/.config" "${HOME}/.config/ghostty" "${HOME}/.config/nvim" "${HOME}/.claude" "${HOME}/.ssh" "${HOME}/Library/Application Support/Code/User"; do
    [[ -d "$dir" ]] || continue
    while IFS= read -r f; do trash_path "$f"; done < <(find "$dir" -maxdepth 1 -type f -name '*.bak.[0-9]*-[0-9]*' 2>/dev/null | sort)
  done

  ui_note "Left in place: ~/.claude/projects (sessions), ~/.ssh keys, ~/Development"
}

tier_runtimes() {
  ui_header "runtimes"
  remove_tree "${HOME}/.nvm"                 # Node versions + global npm packages
  remove_tree "${HOME}/.asdf"                # Erlang/Elixir builds
  trash_path  "${HOME}/.tool-versions"
  remove_tree "${HOME}/.rustup"
  remove_tree "${HOME}/.cargo"
  remove_tree "${HOME}/.local/share/uv"      # uv-managed Pythons
  remove_tree "${HOME}/.cache/uv"
  remove_tree "${HOME}/go"                   # GOPATH: gopls, staticcheck, module cache
  remove_tree "${HOME}/.llamavm"
  ui_note "Left in place: ~/Library/Developer (simulators, DerivedData) — remove by hand if you want it gone"
}

tier_apps() {
  ui_header "apps"
  if have_brew; then
    local installed cask to_zap=()
    installed="$(brew list --cask 2>/dev/null || true)"
    for cask in ${CASKS[@]+"${CASKS[@]}"}; do
      grep -qx "${cask##*/}" <<< "$installed" && to_zap+=("$cask")
    done
    if [[ ${#to_zap[@]} -gt 0 ]]; then
      # --zap also removes the app's preferences, caches, and support files.
      run brew uninstall --cask --zap --force ${to_zap[@]+"${to_zap[@]}"}
    else
      ui_skip "No setup-installed casks present"
    fi
  else
    ui_skip "Homebrew not installed; no casks to remove"
  fi

  if command -v mas >/dev/null 2>&1; then
    local id
    for id in ${MAS_IDS[@]+"${MAS_IDS[@]}"}; do
      if mas list 2>/dev/null | grep -q "^${id} "; then
        run mas uninstall "$id"
      fi
    done
  fi

  local app
  for app in /Applications/Xcode.app /Applications/Xcode-*.app; do
    [[ -d "$app" ]] && run sudo rm -rf "$app"
  done
  return 0
}

tier_packages() {
  ui_header "packages"
  if ! have_brew; then
    ui_skip "Homebrew not installed; no formulae to remove"
    return 0
  fi
  local installed f to_remove=()
  installed="$(brew list --formula 2>/dev/null || true)"
  for f in ${FORMULAE[@]+"${FORMULAE[@]}"}; do
    grep -qx "${f##*/}" <<< "$installed" && to_remove+=("$f")
  done
  if [[ ${#to_remove[@]} -gt 0 ]]; then
    # --ignore-dependencies: we're removing the whole set; autoremove sweeps the rest.
    run brew uninstall --force --ignore-dependencies ${to_remove[@]+"${to_remove[@]}"}
    run brew autoremove
  else
    ui_skip "No setup-installed formulae present"
  fi
  local tap tapped
  tapped="$(brew tap 2>/dev/null || true)"
  for tap in ${TAPS[@]+"${TAPS[@]}"}; do
    if grep -qx "$tap" <<< "$tapped"; then
      run brew untap "$tap"
    fi
  done
  return 0
}

tier_defaults() {
  ui_header "defaults"
  local entry domain key changed=0
  for entry in ${DEFAULT_KEYS[@]+"${DEFAULT_KEYS[@]}"}; do
    domain="${entry% *}"; key="${entry#* }"
    if defaults read "$domain" "$key" >/dev/null 2>&1; then
      run defaults delete "$domain" "$key"
      changed=1
    fi
  done
  if [[ "$changed" == "1" ]]; then
    run killall Dock || true
    run killall Finder || true
    run killall SystemUIServer || true
  else
    ui_skip "No setup-managed defaults are set"
  fi
}

tier_homebrew() {
  ui_header "homebrew"
  if have_brew; then
    uninstall_homebrew() {
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)" -- --force  # dry-run: safe (called via run)
    }
    run uninstall_homebrew
    run sudo rm -rf /opt/homebrew
  else
    ui_skip "Homebrew not installed"
  fi
  # brew_ensure appended the shellenv line to ~/.zprofile.
  if [[ -f "${HOME}/.zprofile" ]] && grep -Fq 'brew shellenv' "${HOME}/.zprofile"; then
    strip_brew_shellenv() { sed -i '' '/brew shellenv/d' "${HOME}/.zprofile"; }  # dry-run: safe (called via run)
    run strip_brew_shellenv
  fi
  remove_tree "${HOME}/.homebrew"                    # tap trust store
  remove_tree "${HOME}/Library/Caches/Homebrew"
  remove_tree "${HOME}/Library/Logs/Homebrew"
  if [[ -d /Library/Developer/CommandLineTools ]]; then
    run sudo rm -rf /Library/Developer/CommandLineTools
  fi
  ui_note "Rosetta 2 cannot be uninstalled; a factory reset removes it."
}

# ── Main ─────────────────────────────────────────────────────────────

START_TIME="$SECONDS"
ui_welcome
if dry_run; then
  ui_note "Dry run: showing what --apply would remove. Nothing changes."
else
  ui_step "This will remove everything in these tiers: ${TIERS[*]}"
  ui_note "Config files go to $(pretty_path "$TRASH")/; runtimes, apps, and packages are deleted."
  printf '  Type "uninstall" to continue: '
  read -r answer
  if [[ "$answer" != "uninstall" ]]; then
    echo "  Aborted."
    exit 1
  fi
  if tier_selected apps || tier_selected homebrew; then
    ui_step "Removing apps and Homebrew needs administrator rights."
    sudo_keepalive_start
  fi
fi
trap 'sudo_keepalive_stop' EXIT

ui_progress_init "${#TIERS[@]}"
for t in configs runtimes apps packages defaults homebrew; do
  tier_selected "$t" && "tier_${t}"
done

ui_show_notes
ui_complete "$(( SECONDS - START_TIME ))" "Uninstall complete"
if ! dry_run; then
  ui_note "Recoverable files are in $(pretty_path "$TRASH")/. Open a new terminal; the old shell still has stale PATH entries."
fi
