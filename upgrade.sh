#!/usr/bin/env bash
#
# Bring everything setup.sh installed up to date. setup.sh only installs what
# is missing; this is the "update the machine" companion.
#
#   ./upgrade.sh                # everything (except Xcode)
#   ./upgrade.sh --dry-run      # show what would be upgraded
#   ./upgrade.sh brew mas       # only some sections
#   ./upgrade.sh --greedy       # also upgrade casks that normally self-update

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
Usage: ./upgrade.sh [options] [section ...]

Sections (default: all except xcode, in this order):
  brew      brew update, then upgrade outdated formulae and casks
  mas       Upgrade outdated Mac App Store apps (needs App Store sign-in)
  node      Install the current Node LTS and repin the default (via install/91-node.sh)
  elixir    Install the latest Erlang/Elixir and set as global (via install/90-elixir.sh)
  rust      rustup update
  python    uv python upgrade (managed CPython builds)
  npm       npm update -g inside the active nvm Node
  claude    claude update
  codex     codex update
  vscode    code --update-extensions
  cleanup   brew autoremove + brew cleanup
  xcode     xcodes install --latest (Apple ID; only when asked for explicitly)

Options:
  -n, --dry-run   Report what would be upgraded without changing anything
  -g, --greedy    Also upgrade casks marked auto_updates (Chrome, Slack, ...)
  -h, --help
USAGE
}

export DRY_RUN=0
GREEDY=0
SECTIONS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    -g|--greedy) GREEDY=1 ;;
    brew|mas|node|elixir|rust|python|npm|claude|codex|vscode|cleanup|xcode) SECTIONS+=("$1") ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done
[[ ${#SECTIONS[@]} -eq 0 ]] && SECTIONS=(brew mas node elixir rust python npm claude codex vscode cleanup)

export HOMEBREW_NO_ASK=1 HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ENV_HINTS=1

selected() { local s; for s in "${SECTIONS[@]}"; do [[ "$s" == "$1" ]] && return 0; done; return 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# Run one of the installers exactly as setup.sh would (sourced, same helpers).
run_installer() {
  local name="$1"
  # shellcheck source=/dev/null
  source "${ROOT_DIR}/install/${name}.sh"
}

# ── Sections ─────────────────────────────────────────────────────────

section_brew() {
  ui_header "brew"
  if ! have brew; then ui_skip "Homebrew not installed"; return 0; fi
  run brew update

  local outdated line
  outdated="$(brew outdated --formula --verbose 2>/dev/null || true)"
  if [[ -z "$outdated" ]]; then
    ui_skip "All formulae up to date"
  elif dry_run; then
    while IFS= read -r line; do [[ -n "$line" ]] && ui_plan "upgrade formula $line"; done <<< "$outdated"
  else
    run brew upgrade --formula
    ui_success "Formulae upgraded"
  fi

  local greedy=()
  [[ "$GREEDY" == "1" ]] && greedy=(--greedy)
  outdated="$(brew outdated --cask --verbose ${greedy[@]+"${greedy[@]}"} 2>/dev/null || true)"
  if [[ -z "$outdated" ]]; then
    ui_skip "All casks up to date${GREEDY:+ (self-updating apps skipped; use --greedy)}"
  elif dry_run; then
    while IFS= read -r line; do [[ -n "$line" ]] && ui_plan "upgrade cask $line"; done <<< "$outdated"
  else
    run brew upgrade --cask ${greedy[@]+"${greedy[@]}"}
    ui_success "Casks upgraded"
  fi
}

section_mas() {
  ui_header "mas"
  if ! have mas; then ui_skip "mas not installed"; return 0; fi
  local outdated line
  outdated="$(mas outdated 2>/dev/null || true)"
  if [[ -z "$outdated" ]]; then
    ui_skip "All App Store apps up to date"
  elif dry_run; then
    while IFS= read -r line; do [[ -n "$line" ]] && ui_plan "upgrade App Store app $line"; done <<< "$outdated"
  else
    run mas upgrade || log "NOTE: mas upgrade failed — is App Store.app signed in?"
  fi
}

section_node()   { ui_header "node";   run_installer 91-node; }
section_elixir() { ui_header "elixir"; run_installer 90-elixir; }

section_rust() {
  ui_header "rust"
  if ! have rustup; then ui_skip "rustup not installed"; return 0; fi
  if rustup check 2>/dev/null | grep -q 'Update available'; then
    run rustup update
  else
    ui_skip "Rust toolchains up to date"
  fi
}

section_python() {
  ui_header "python"
  if ! have uv; then ui_skip "uv not installed"; return 0; fi
  # Upgrades uv-managed CPython builds to their latest patch releases.
  run uv python upgrade
}

section_npm() {
  ui_header "npm"
  export NVM_DIR="${HOME}/.nvm"
  # shellcheck source=/dev/null
  [[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh" >/dev/null 2>&1 || true
  if ! have npm; then ui_skip "npm not available"; return 0; fi
  local outdated
  outdated="$(npm outdated -g --parseable 2>/dev/null | awk -F: '{print $3 " -> " $4}' || true)"
  if [[ -z "$outdated" ]]; then
    ui_skip "Global npm packages up to date"
  elif dry_run; then
    while IFS= read -r line; do [[ -n "$line" ]] && ui_plan "update npm global $line"; done <<< "$outdated"
  else
    run npm update -g
    ui_success "Global npm packages updated"
  fi
}

section_claude() {
  ui_header "claude"
  if ! have claude; then ui_skip "Claude Code not installed"; return 0; fi
  run claude update || true
}

section_codex() {
  ui_header "codex"
  if ! have codex; then ui_skip "Codex not installed"; return 0; fi
  run codex update || true
}

section_vscode() {
  ui_header "vscode"
  local code_bin=""
  if have code; then code_bin="code"
  elif [[ -x "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" ]]; then
    code_bin="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
  fi
  if [[ -z "$code_bin" ]]; then ui_skip "VS Code not installed"; return 0; fi
  run "$code_bin" --update-extensions
}

section_cleanup() {
  ui_header "cleanup"
  if ! have brew; then ui_skip "Homebrew not installed"; return 0; fi
  run brew autoremove
  run brew cleanup
}

section_xcode() {
  ui_header "xcode"
  if ! have xcodes; then ui_skip "xcodes not installed"; return 0; fi
  log "NOTE: xcodes needs an Apple ID (XCODES_USERNAME/XCODES_PASSWORD or an interactive prompt). App Store-installed Xcode is covered by the mas section instead."
  run xcodes install --latest --experimental-unxip --no-superuser --select
}

# ── Main ─────────────────────────────────────────────────────────────

START_TIME="$SECONDS"
ui_welcome
if dry_run; then
  ui_note "Dry run: reporting what would be upgraded; nothing changes."
elif [[ -t 0 ]] && { selected brew || selected mas; }; then
  # .pkg casks and mas need root; cache it once like setup.sh does.
  ui_step "Cask and App Store upgrades may need administrator rights."
  sudo_keepalive_start
fi
trap 'sudo_keepalive_stop' EXIT

ui_progress_init "${#SECTIONS[@]}"
for s in brew mas node elixir rust python npm claude codex vscode cleanup xcode; do
  selected "$s" && "section_${s}"
done

ui_show_notes
ui_complete "$(( SECONDS - START_TIME ))" "Upgrade complete"
