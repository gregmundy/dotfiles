#!/usr/bin/env bash
set -euo pipefail

have_brew() { command -v brew >/dev/null 2>&1; }

brew_ensure() {
  if have_brew; then
    return 0
  fi
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    ui_plan "install Homebrew (everything below assumes it is present)"
    return 0
  fi

  # NONINTERACTIVE skips the "Press RETURN to continue" pause. The installer
  # uses the sudo ticket setup.sh cached, then runs `sudo -k` on exit, which
  # throws that ticket away — so re-validate once afterwards or every later
  # root step (mas, xcode-select, .pkg casks) prompts again.
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ "${SETUP_SUDO_CACHED:-0}" == "1" ]]; then
    ui_step "Homebrew's installer cleared the sudo session; enter your password once more."
    sudo -v
  fi

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

# Formulas install under a quiet spinner. This is safe only because nothing
# can prompt any more: setup.sh exports HOMEBREW_NO_ASK=1 (no dependency
# confirmation), 00-homebrew.sh ensures the Command Line Tools and runs the
# one-time `brew update`. ui_spin passes --show-error, so a failed install
# still prints brew's output.
brew_install_formula() {
  local name="$1"
  if brew_has_formula "$name"; then
    ui_skip "$name"
  elif [[ "${DRY_RUN:-0}" == "1" ]]; then
    ui_plan "install formula $name"
  else
    ui_spin "Installing $name..." brew install "$name"
    ui_success "$name"
  fi
}

# Homebrew needs the Command Line Tools to install anything. Its own installer
# sets them up, but a pre-installed brew (or a macOS upgrade that invalidated
# them) can leave a machine where the first formula install silently stalls on
# the CLT prompt. Kick off the install and wait for it before continuing.
brew_ensure_clt() {
  if xcode-select -p >/dev/null 2>&1 && [[ -d "$(xcode-select -p)/usr/bin" ]]; then
    ui_skip "Command Line Tools present"
    return 0
  fi

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    ui_plan "install Xcode Command Line Tools"
    return 0
  fi
  ui_step "Installing Xcode Command Line Tools (approve the macOS dialog)..."
  xcode-select --install >/dev/null 2>&1 || true
  local waited=0
  until xcode-select -p >/dev/null 2>&1; do
    sleep 10
    waited=$(( waited + 10 ))
    if (( waited % 60 == 0 )); then
      ui_step "Still waiting for Command Line Tools (${waited}s)..."
    fi
  done
  ui_success "Command Line Tools installed"
}

# Add a third-party tap and mark it trusted. Homebrew now refuses to load
# formulae/casks from non-official taps until `brew trust --tap` has been run
# (HOMEBREW_REQUIRE_TAP_TRUST defaults on), so a plain `brew tap` followed by
# an install fails with "untrusted tap".
brew_tap_trusted() {
  local tap="$1" info
  # Capture rather than pipe into `grep -q`: under pipefail an early grep exit
  # SIGPIPEs brew and the whole test reads as false.
  info="$(brew tap-info "$tap" 2>&1 || true)"
  if [[ "$info" == *"Not installed"* ]]; then
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
      ui_plan "tap and trust $tap"
      return 0
    fi
    ui_step "Tapping $tap..."
    brew tap "$tap"
    info="$(brew tap-info "$tap" 2>&1 || true)"
  fi
  if [[ $'\n'"$info"$'\n' == *$'\nTrusted\n'* ]]; then
    ui_skip "$tap trusted"
  elif [[ "${DRY_RUN:-0}" == "1" ]]; then
    ui_plan "trust tap $tap"
  else
    brew trust --tap "$tap" >/dev/null
    ui_success "$tap trusted"
  fi
}

brew_install_cask() {
  local name="$1"
  if brew_has_cask "$name"; then
    ui_skip "$name"
  elif [[ "${DRY_RUN:-0}" == "1" ]]; then
    ui_plan "install cask $name"
  else
    # No spinner — some casks prompt for sudo (e.g. Zoom, 1Password)
    # and gum spin swallows the password prompt
    ui_step "Installing $name..."
    # --adopt takes over an existing app bundle at the target path
    # (e.g. manually-installed LM Studio) instead of erroring
    brew install --cask --adopt "$name"
    ui_success "$name"
  fi
}
