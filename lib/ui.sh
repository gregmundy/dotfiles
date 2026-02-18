#!/usr/bin/env bash
set -euo pipefail

# UI helpers powered by gum (https://github.com/charmbracelet/gum)
# All functions fall back to plain text if gum is not available.
#
# Color palette (hex):
#   Accent:  #7C3AED (purple)
#   Success: #22C55E (green)
#   Error:   #EF4444 (red)
#   Muted:   #6B7280 (gray)
#   Text:    #E5E7EB (light)

_have_gum() { command -v gum >/dev/null 2>&1; }

# ── Progress tracking ────────────────────────────────────────────────
# Call ui_progress_init with total step count before the loop.
# Call ui_header for each step (auto-increments).

# Only init on first source (avoid reset when installers re-source bootstrap)
if [[ -z "${_UI_STEP_CURRENT:-}" ]]; then
  _UI_STEP_CURRENT=0
  _UI_STEP_TOTAL=0
fi

ui_progress_init() {
  _UI_STEP_CURRENT=0
  _UI_STEP_TOTAL="$1"
}

# ── Section header with step counter ─────────────────────────────────

ui_header() {
  local title="$1"
  _UI_STEP_CURRENT=$(( _UI_STEP_CURRENT + 1 ))

  echo ""
  if _have_gum; then
    local counter=""
    if [[ "$_UI_STEP_TOTAL" -gt 0 ]]; then
      counter="$(gum style --foreground '#6B7280' "[${_UI_STEP_CURRENT}/${_UI_STEP_TOTAL}]") "
    fi
    local label
    label="$(gum style --bold --foreground '#7C3AED' "$title")"
    local line
    line="$(gum style --foreground '#3F3F46' "────────────────────────────────────────")"
    echo " ${counter}${label}"
    echo " ${line}"
  else
    if [[ "$_UI_STEP_TOTAL" -gt 0 ]]; then
      echo "[${_UI_STEP_CURRENT}/${_UI_STEP_TOTAL}] $title"
    else
      echo "=== $title ==="
    fi
  fi
}

# ── Step in progress ─────────────────────────────────────────────────

ui_step() {
  local msg="$1"
  if _have_gum; then
    local icon
    icon="$(gum style --foreground '#7C3AED' "›")"
    gum style " ${icon} ${msg}"
  else
    echo "  $msg"
  fi
}

# ── Success (new install) ────────────────────────────────────────────

ui_success() {
  local msg="$1"
  if _have_gum; then
    local icon
    icon="$(gum style --foreground '#22C55E' "✓")"
    gum style " ${icon} ${msg}"
  else
    echo "  ✓ $msg"
  fi
}

# ── Already present (dimmed) ─────────────────────────────────────────

ui_skip() {
  local msg="$1"
  if _have_gum; then
    gum style --foreground '#6B7280' " ✓ ${msg}"
  else
    echo "  ✓ $msg"
  fi
}

# ── Error ────────────────────────────────────────────────────────────

ui_error() {
  local msg="$1"
  if _have_gum; then
    local icon
    icon="$(gum style --bold --foreground '#EF4444' "✗")"
    gum style --bold " ${icon} ${msg}"
  else
    echo "  ERROR: $msg" >&2
  fi
}

# ── Note (subdued) ───────────────────────────────────────────────────

ui_note() {
  local msg="$1"
  if _have_gum; then
    local icon
    icon="$(gum style --foreground '#6B7280' "↳")"
    gum style --foreground '#6B7280' --italic " ${icon} ${msg}"
  else
    echo "  NOTE: $msg"
  fi
}

# ── Styled text input ────────────────────────────────────────────────

ui_input() {
  local prompt="$1"
  local result
  if _have_gum; then
    result="$(gum input \
      --prompt "  $prompt " \
      --prompt.foreground '#7C3AED' \
      --placeholder "..." \
      --cursor.foreground '#7C3AED' \
      --width 50)"
  else
    read -rp "  $prompt " result
  fi
  echo "$result"
}

# ── Spinner wrapping a command ───────────────────────────────────────

ui_spin() {
  local msg="$1"
  shift
  if _have_gum; then
    gum spin \
      --spinner pulse \
      --spinner.foreground '#7C3AED' \
      --title " $msg" \
      --title.foreground '#E5E7EB' \
      -- "$@"
  else
    echo "  $msg"
    "$@"
  fi
}

# ── Welcome banner ───────────────────────────────────────────────────

ui_welcome() {
  if _have_gum; then
    echo ""
    gum style \
      --foreground '#7C3AED' \
      --bold \
      "  ●  dotfiles"
    gum style \
      --foreground '#6B7280' \
      --italic \
      "  Your dev environment, automated."
    echo ""
    gum style --foreground '#3F3F46' \
      "  ──────────────────────────────────────────"
  else
    echo ""
    echo "  dotfiles - Your dev environment, automated."
    echo ""
  fi
}

# ── Completion banner ────────────────────────────────────────────────

ui_complete() {
  local elapsed="$1"
  echo ""
  if _have_gum; then
    gum style --foreground '#3F3F46' \
      "  ──────────────────────────────────────────"
    echo ""
    local check
    check="$(gum style --foreground '#22C55E' --bold "✓")"
    local msg
    msg="$(gum style --bold "Setup complete")"
    local time
    time="$(gum style --foreground '#6B7280' "in ${elapsed}s")"
    echo "  ${check} ${msg} ${time}"
  else
    echo "  ✓ Setup complete in ${elapsed}s"
  fi
  echo ""
}
