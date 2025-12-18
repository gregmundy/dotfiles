#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

ZSHRC="${HOME}/.zshrc"
ZSH_DIR="${HOME}/.oh-my-zsh"
ZSH_CUSTOM="${ZSH_CUSTOM:-${ZSH_DIR}/custom}"
ZSH_PLUGINS_DIR="${ZSH_CUSTOM}/plugins"

ensure_login_shell_is_zsh() {
  local current_shell
  current_shell="$(dscl . -read "${HOME}" UserShell 2>/dev/null | awk '{print $2}' || true)"

  if [[ "$current_shell" == "/bin/zsh" ]]; then
    log "✓ Login shell is already zsh (/bin/zsh)"
    return 0
  fi

  log "Your login shell is: ${current_shell:-"(unknown)"}"
  log "If you want to switch to zsh, run: chsh -s /bin/zsh"
}

ensure_zsh_theme() {
  local theme="$1"
  touch "$ZSHRC"

  # Check if theme is already set correctly
  if grep -Eq "^ZSH_THEME=\"${theme}\"" "$ZSHRC"; then
    log "✓ ZSH_THEME already set to ${theme}"
    return 0
  fi

  if grep -Eq '^ZSH_THEME=' "$ZSHRC"; then
    sed -i '' "s/^ZSH_THEME=.*/ZSH_THEME=\"${theme}\"/" "$ZSHRC"
    log "✓ Updated ZSH_THEME to ${theme}"
  else
    echo "ZSH_THEME=\"${theme}\"" >> "$ZSHRC"
    log "✓ Added ZSH_THEME=${theme}"
  fi
}

# Check if plugins line contains all required plugins in correct order
plugins_need_update() {
  local existing="$1"
  # Check for required plugins
  for plugin in git direnv asdf zsh-autosuggestions; do
    if [[ "$existing" != *"$plugin"* ]]; then
      return 0  # needs update
    fi
  done
  # Check that zsh-syntax-highlighting is present and last
  if [[ "$existing" != *"zsh-syntax-highlighting)" ]]; then
    return 0  # needs update
  fi
  return 1  # no update needed
}

# Extract first plugins=(...) line content (best effort, single-line)
get_plugins_line() {
  grep -E '^[[:space:]]*plugins=\(' "$ZSHRC" | head -n 1 || true
}

# Build a normalized plugins line ensuring:
# - includes direnv (OMZ built-in)
# - includes asdf (OMZ built-in)
# - includes zsh-autosuggestions (custom plugin)
# - includes zsh-syntax-highlighting (custom plugin) LAST
normalize_plugins_line() {
  local line="$1"

  # Strip prefix/suffix to get the inside of (...)
  local inside
  inside="$(echo "$line" | sed -E 's/^[[:space:]]*plugins=\(//; s/\)[[:space:]]*$//')"

  # shellcheck disable=SC2206
  local tokens=($inside)

  local out=()
  local seen=" "
  local t

  for t in "${tokens[@]}"; do
    [[ -z "$t" ]] && continue
    [[ "$t" == "#"* ]] && continue

    # handle highlighting last
    if [[ "$t" == "zsh-syntax-highlighting" ]]; then
      continue
    fi

    # dedupe
    if [[ "$seen" != *" $t "* ]]; then
      out+=("$t")
      seen+=" $t "
    fi
  done

  # Ensure required plugins exist
  for t in direnv asdf zsh-autosuggestions; do
    if [[ "$seen" != *" $t "* ]]; then
      out+=("$t")
      seen+=" $t "
    fi
  done

  # Ensure highlighting is last
  out+=("zsh-syntax-highlighting")

  echo "plugins=(${out[*]})"
}

ensure_plugins_in_zshrc() {
  touch "$ZSHRC"

  local existing
  existing="$(get_plugins_line)"

  if [[ -z "$existing" ]]; then
    echo "plugins=(git direnv asdf zsh-autosuggestions zsh-syntax-highlighting)" >> "$ZSHRC"
    log "✓ Added plugins to .zshrc"
    return 0
  fi

  # Check if update is needed
  if ! plugins_need_update "$existing"; then
    log "✓ Plugins already configured correctly"
    return 0
  fi

  local normalized
  normalized="$(normalize_plugins_line "$existing")"

  awk -v new="$normalized" '
    BEGIN { replaced=0 }
    !replaced && $0 ~ /^[[:space:]]*plugins=\(/ { print new; replaced=1; next }
    { print }
  ' "$ZSHRC" > "${ZSHRC}.tmp"
  mv "${ZSHRC}.tmp" "$ZSHRC"
  log "✓ Updated plugins in .zshrc"
}

# --- begin ----------------------------------------------------------------

log "Checking login shell..."
ensure_login_shell_is_zsh

log "Installing oh-my-zsh (if needed)..."
if [[ -d "$ZSH_DIR" ]]; then
  log "✓ oh-my-zsh already installed"
else
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  log "✓ oh-my-zsh installed"
fi

log "Installing zsh plugins (if needed)..."
mkdir -p "$ZSH_PLUGINS_DIR"

if [[ -d "${ZSH_PLUGINS_DIR}/zsh-autosuggestions" ]]; then
  log "✓ zsh-autosuggestions already installed"
else
  git clone https://github.com/zsh-users/zsh-autosuggestions.git \
    "${ZSH_PLUGINS_DIR}/zsh-autosuggestions"
  log "✓ zsh-autosuggestions installed"
fi

if [[ -d "${ZSH_PLUGINS_DIR}/zsh-syntax-highlighting" ]]; then
  log "✓ zsh-syntax-highlighting already installed"
else
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "${ZSH_PLUGINS_DIR}/zsh-syntax-highlighting"
  log "✓ zsh-syntax-highlighting installed"
fi

log "Configuring plugins in ~/.zshrc..."
ensure_plugins_in_zshrc

log "Configuring theme..."
ensure_zsh_theme steeef

log "✓ Zsh setup complete"
