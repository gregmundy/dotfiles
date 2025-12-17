#!/usr/bin/env bash
set -euo pipefail

ZSHRC="${HOME}/.zshrc"
ZSH_DIR="${HOME}/.oh-my-zsh"
ZSH_CUSTOM="${ZSH_CUSTOM:-${ZSH_DIR}/custom}"
ZSH_PLUGINS_DIR="${ZSH_CUSTOM}/plugins"

backup_file_once_per_run() {
  local file="$1"
  if [[ -f "$file" ]]; then
    local ts backup
    ts="$(date +"%Y%m%d-%H%M%S")"
    backup="${file}.bak.${ts}"
    cp -p "$file" "$backup"
    echo "✓ Backed up $(basename "$file") -> $(basename "$backup")"
  fi
}

ensure_login_shell_is_zsh() {
  local current_shell
  current_shell="$(dscl . -read "${HOME}" UserShell 2>/dev/null | awk '{print $2}' || true)"

  if [[ "$current_shell" == "/bin/zsh" ]]; then
    echo "✓ Login shell is already zsh (/bin/zsh)"
    return 0
  fi

  echo "ℹ️  Your login shell is: ${current_shell:-"(unknown)"}"
  echo "   If you want to switch to zsh, run:"
  echo "     chsh -s /bin/zsh"
}

ensure_zsh_theme() {
  local theme="$1"
  touch "$ZSHRC"

  if grep -Eq '^ZSH_THEME=' "$ZSHRC"; then
    sed -i '' "s/^ZSH_THEME=.*/ZSH_THEME=\"${theme}\"/" "$ZSHRC"
  else
    echo "ZSH_THEME=\"${theme}\"" >> "$ZSHRC"
  fi
}

# Extract first plugins=(...) line content (best effort, single-line)
get_plugins_line() {
  grep -E '^[[:space:]]*plugins=\(' "$ZSHRC" | head -n 1 || true
}

# Build a normalized plugins line ensuring:
# - includes zsh-autosuggestions
# - includes zsh-syntax-highlighting
# - zsh-syntax-highlighting is LAST
normalize_plugins_line() {
  local line="$1"
  # Strip prefix/suffix to get the inside of (...)
  local inside
  inside="$(echo "$line" | sed -E 's/^[[:space:]]*plugins=\(//; s/\)[[:space:]]*$//')"

  # Split tokens, dedupe, remove zsh-syntax-highlighting for now, then append it at end.
  # Keep order of existing tokens as much as possible.
  local tokens=()
  local seen=" "
  local t

  # shellcheck disable=SC2206
  tokens=($inside)

  local out=()
  for t in "${tokens[@]}"; do
    # skip comments or empty
    [[ -z "$t" ]] && continue
    [[ "$t" == "#"* ]] && continue

    # handle highlighting later
    if [[ "$t" == "zsh-syntax-highlighting" ]]; then
      continue
    fi

    # dedupe
    if [[ "$seen" != *" $t "* ]]; then
      out+=("$t")
      seen+=" $t "
    fi
  done

  # Ensure autosuggestions exists
  if [[ "$seen" != *" zsh-autosuggestions "* ]]; then
    out+=("zsh-autosuggestions")
    seen+=" zsh-autosuggestions "
  fi

  # Ensure highlighting is last
  out+=("zsh-syntax-highlighting")

  echo "plugins=(${out[*]})"
}

ensure_plugins_in_zshrc() {
  touch "$ZSHRC"

  local existing
  existing="$(get_plugins_line)"

  if [[ -z "$existing" ]]; then
    # No plugins line: add a reasonable default with highlighting last
    echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)" >> "$ZSHRC"
    return 0
  fi

  local normalized
  normalized="$(normalize_plugins_line "$existing")"

  # Replace ONLY the first plugins=(...) line
  # macOS sed: use an address range trick by replacing the first match only with 0,/pattern/
  # but sed on macOS doesn’t support 0, so we use awk for a “replace first occurrence”.
  awk -v new="$normalized" '
    BEGIN { replaced=0 }
    !replaced && $0 ~ /^[[:space:]]*plugins=\(/ { print new; replaced=1; next }
    { print }
  ' "$ZSHRC" > "${ZSHRC}.tmp"
  mv "${ZSHRC}.tmp" "$ZSHRC"
}

# --- begin ----------------------------------------------------------------

echo "==> Checking login shell..."
ensure_login_shell_is_zsh

echo "==> Preparing to edit ~/.zshrc..."
backup_file_once_per_run "$ZSHRC"

echo "==> Installing oh-my-zsh (if needed)..."
if [[ -d "$ZSH_DIR" ]]; then
  echo "✓ oh-my-zsh already installed"
else
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "==> Installing zsh plugins (if needed)..."
mkdir -p "$ZSH_PLUGINS_DIR"

if [[ -d "${ZSH_PLUGINS_DIR}/zsh-autosuggestions" ]]; then
  echo "✓ zsh-autosuggestions already installed"
else
  git clone https://github.com/zsh-users/zsh-autosuggestions.git \
    "${ZSH_PLUGINS_DIR}/zsh-autosuggestions"
fi

if [[ -d "${ZSH_PLUGINS_DIR}/zsh-syntax-highlighting" ]]; then
  echo "✓ zsh-syntax-highlighting already installed"
else
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "${ZSH_PLUGINS_DIR}/zsh-syntax-highlighting"
fi

echo "==> Enabling plugins in ~/.zshrc (syntax-highlighting last)..."
ensure_plugins_in_zshrc

echo "==> Setting oh-my-zsh theme to steeef..."
ensure_zsh_theme steeef

echo "✅ Zsh setup complete."
echo "Restart your terminal or run: source ~/.zshrc"
