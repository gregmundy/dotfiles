#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing Claude Code global config..."

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${REPO_ROOT}/dotfiles/claude/settings.json"
DEST_DIR="${HOME}/.claude"
DEST="${DEST_DIR}/settings.json"

if [[ ! -f "${SRC}" ]]; then
  log "ERROR: Missing ${SRC}"
  return 1
fi

ensure_dir "${DEST_DIR}"

# No existing config — straight copy.
if [[ ! -f "${DEST}" ]]; then
  deploy_file "${SRC}" "${DEST}"
  log "NOTE: Session-accepted permissions still go to ~/.claude/settings.local.json — not managed here."
  return 0
fi

# Merge rather than overwrite. Claude Code writes machine-local keys into this
# file at runtime (autoMode, onboarding state, per-project trust). A blind copy
# would silently discard them on every setup run.
#
# Semantics of `.[0] * .[1]`: deep merge with the repo (second input) winning on
# conflicts, and keys present only in the live file preserved untouched. Arrays
# are replaced wholesale, so dotfiles/claude/settings.json must carry the full
# desired permissions.allow list — it is the source of truth for that key.
if ! command -v jq &>/dev/null; then
  log "ERROR: jq not found — cannot merge settings.json safely. Run 05-misc-deps.sh first."
  return 1
fi

MERGED="$(mktemp)"
if ! jq -s '.[0] * .[1]' "${DEST}" "${SRC}" > "${MERGED}" 2>/dev/null; then
  rm -f "${MERGED}"  # dry-run: safe (temp file)
  log "ERROR: Failed to merge ${DEST} (is it valid JSON?)"
  return 1
fi

if jq -e --slurpfile a "${DEST}" --slurpfile b "${MERGED}" -n '$a[0] == $b[0]' >/dev/null 2>&1; then
  rm -f "${MERGED}"  # dry-run: safe (temp file)
  log "✓ Claude settings.json already up to date"
elif dry_run; then
  rm -f "${MERGED}"  # dry-run: safe (temp file)
  ui_plan "merge repo settings into ~/.claude/settings.json (backup kept)"
else
  TS="$(date +"%Y%m%d-%H%M%S")"
  cp -a "${DEST}" "${DEST}.bak.${TS}"  # dry-run: safe (dry run returns above)
  log "Backed up existing settings.json to ${DEST}.bak.${TS}"
  # Preserve destination permissions/ownership rather than mv'ing the mktemp file.
  cat "${MERGED}" > "${DEST}"  # dry-run: safe (dry run returns above)
  rm -f "${MERGED}"  # dry-run: safe (temp file)
  log "✓ Merged repo settings into ${DEST}"
fi

log "NOTE: Repo settings win on conflict; machine-local keys (autoMode, etc.) are preserved."
log "NOTE: Session-accepted permissions still go to ~/.claude/settings.local.json — not managed here."
