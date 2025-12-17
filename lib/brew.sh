#!/usr/bin/env bash
set -euo pipefail

have_brew() { command -v brew >/dev/null 2>&1; }

brew_ensure() {
  if have_brew; then
    return 0
  fi

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for future shells + current run
  local BREW_SHELLENV_A='eval "$(/opt/homebrew/bin/brew shellenv)"'
  local BREW_SHELLENV_I='eval "$(/usr/local/bin/brew shellenv)"'

  touch "${HOME}/.zprofile"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    grep -Fqs "$BREW_SHELLENV_A" "${HOME}/.zprofile" || {
      echo "" >> "${HOME}/.zprofile"
      echo "$BREW_SHELLENV_A" >> "${HOME}/.zprofile"
    }
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    grep -Fqs "$BREW_SHELLENV_I" "${HOME}/.zprofile" || {
      echo "" >> "${HOME}/.zprofile"
      echo "$BREW_SHELLENV_I" >> "${HOME}/.zprofile"
    }
    eval "$(/usr/local/bin/brew shellenv)"
  else
    echo "ERROR: Homebrew installed but brew binary not found at expected paths." >&2
    exit 1
  fi
}

brew_has_formula() { brew list --formula "$1" >/dev/null 2>&1; }
brew_has_cask()    { brew list --cask "$1" >/dev/null 2>&1; }

brew_install_formula() {
  local name="$1"
  if brew_has_formula "$name"; then
    echo "✓ Already installed (formula): $name"
  else
    brew install "$name"
  fi
}

brew_install_cask() {
  local name="$1"
  if brew_has_cask "$name"; then
    echo "✓ Already installed (cask): $name"
  else
    brew install --cask "$name"
  fi
}

