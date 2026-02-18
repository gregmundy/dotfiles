#!/usr/bin/env bash
set -euo pipefail

# UI helpers powered by gum (https://github.com/charmbracelet/gum)
# All functions fall back to plain text if gum is not available.

_have_gum() { command -v gum >/dev/null 2>&1; }

# Styled section header
ui_header() {
  local title="$1"
  if _have_gum; then
    echo ""
    gum style --bold --foreground 4 --border rounded --padding "0 2" "$title"
  else
    echo ""
    echo "=== $title ==="
  fi
}

# Current action (no icon)
ui_step() {
  local msg="$1"
  if _have_gum; then
    gum style --foreground 7 "  $msg"
  else
    echo "  $msg"
  fi
}

# Green checkmark
ui_success() {
  local msg="$1"
  if _have_gum; then
    gum style --foreground 2 "  ✓ $msg"
  else
    echo "  ✓ $msg"
  fi
}

# Red error
ui_error() {
  local msg="$1"
  if _have_gum; then
    gum style --foreground 1 --bold "  ✗ $msg"
  else
    echo "  ERROR: $msg" >&2
  fi
}

# Dim note
ui_note() {
  local msg="$1"
  if _have_gum; then
    gum style --faint --italic "  $msg"
  else
    echo "  NOTE: $msg"
  fi
}

# Styled text input (returns user input via stdout)
ui_input() {
  local prompt="$1"
  local result
  if _have_gum; then
    result="$(gum input --prompt "  $prompt " --placeholder "..." --width 50)"
  else
    read -rp "  $prompt " result
  fi
  echo "$result"
}

# Spinner wrapping a command
ui_spin() {
  local msg="$1"
  shift
  if _have_gum; then
    gum spin --spinner dot --title "  $msg" -- "$@"
  else
    echo "  $msg"
    "$@"
  fi
}
