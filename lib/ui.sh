#!/usr/bin/env bash
set -euo pipefail

# UI helpers powered by gum (https://github.com/charmbracelet/gum)
# All functions fall back to plain text if gum is not available.
#
# Color palette (hex):
#   Accent:  #7C3AED (purple)
#   Alt:     #A78BFA (light purple)
#   Success: #22C55E (green)
#   Error:   #EF4444 (red)
#   Warn:    #F59E0B (amber)
#   Muted:   #6B7280 (gray)
#   Dim:     #3F3F46 (dark gray)
#   Text:    #E5E7EB (light)

_have_gum() { command -v gum >/dev/null 2>&1; }

# ── Counters ─────────────────────────────────────────────────────────
# Track stats for the completion summary.

if [[ -z "${_UI_STEP_CURRENT:-}" ]]; then
  _UI_STEP_CURRENT=0
  _UI_STEP_TOTAL=0
  _UI_COUNT_INSTALLED=0
  _UI_COUNT_SKIPPED=0
  _UI_COUNT_ERRORS=0
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
  _UI_COUNT_INSTALLED=$(( _UI_COUNT_INSTALLED + 1 ))
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
  _UI_COUNT_SKIPPED=$(( _UI_COUNT_SKIPPED + 1 ))
  if _have_gum; then
    gum style --foreground '#6B7280' " ◇ ${msg}"
  else
    echo "  - $msg (exists)"
  fi
}

# ── Error ────────────────────────────────────────────────────────────

ui_error() {
  local msg="$1"
  _UI_COUNT_ERRORS=$(( _UI_COUNT_ERRORS + 1 ))
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
      --prompt.foreground '#A78BFA' \
      --placeholder "..." \
      --cursor.foreground '#7C3AED' \
      --width 50)"
  else
    read -rp "  $prompt " result
  fi
  echo "$result"
}

# ── Spinners ─────────────────────────────────────────────────────────
# Different spinners for different operation types.

# General purpose (default)
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

# Download / network operations
ui_spin_download() {
  local msg="$1"
  shift
  if _have_gum; then
    gum spin \
      --spinner globe \
      --spinner.foreground '#60A5FA' \
      --title " ↓ $msg" \
      --title.foreground '#E5E7EB' \
      -- "$@"
  else
    echo "  ↓ $msg"
    "$@"
  fi
}

# Config / file deployment
ui_spin_config() {
  local msg="$1"
  shift
  if _have_gum; then
    gum spin \
      --spinner dot \
      --spinner.foreground '#A78BFA' \
      --title " → $msg" \
      --title.foreground '#E5E7EB' \
      -- "$@"
  else
    echo "  → $msg"
    "$@"
  fi
}

# Build / compile operations
ui_spin_build() {
  local msg="$1"
  shift
  if _have_gum; then
    gum spin \
      --spinner meter \
      --spinner.foreground '#F59E0B' \
      --title " ⚙ $msg" \
      --title.foreground '#E5E7EB' \
      -- "$@"
  else
    echo "  ⚙ $msg"
    "$@"
  fi
}

# ── Welcome banner ───────────────────────────────────────────────────

ui_welcome() {
  if _have_gum; then
    echo ""
    gum style \
      --border rounded \
      --border-foreground '#3F3F46' \
      --padding "1 3" \
      --align center \
      "$(gum style --bold --foreground '#7C3AED' '●  d o t f i l e s')" \
      "" \
      "$(gum style --foreground '#6B7280' --italic 'Your dev environment, automated.')"
    echo ""
  else
    echo ""
    echo "  dotfiles - Your dev environment, automated."
    echo ""
  fi
}

# ── Completion banner ────────────────────────────────────────────────

ui_complete() {
  local elapsed="$1"

  # Format elapsed time nicely
  local time_str
  if [[ "$elapsed" -ge 60 ]]; then
    local mins=$(( elapsed / 60 ))
    local secs=$(( elapsed % 60 ))
    time_str="${mins}m ${secs}s"
  else
    time_str="${elapsed}s"
  fi

  echo ""
  if _have_gum; then
    # Stats line
    local stats
    local installed
    installed="$(gum style --foreground '#22C55E' "${_UI_COUNT_INSTALLED} installed")"
    local skipped
    skipped="$(gum style --foreground '#6B7280' "${_UI_COUNT_SKIPPED} unchanged")"
    if [[ "$_UI_COUNT_ERRORS" -gt 0 ]]; then
      local errors
      errors="$(gum style --foreground '#EF4444' "${_UI_COUNT_ERRORS} errors")"
      stats="${installed}  ·  ${skipped}  ·  ${errors}"
    else
      stats="${installed}  ·  ${skipped}"
    fi

    gum style \
      --border rounded \
      --border-foreground '#3F3F46' \
      --padding "1 3" \
      --align center \
      "$(gum style --foreground '#22C55E' --bold '✓  Setup complete')" \
      "" \
      "${stats}" \
      "$(gum style --foreground '#6B7280' "${time_str}")"
  else
    echo "  ✓ Setup complete in ${time_str}"
    echo "    ${_UI_COUNT_INSTALLED} installed, ${_UI_COUNT_SKIPPED} unchanged, ${_UI_COUNT_ERRORS} errors"
  fi
  echo ""
}
