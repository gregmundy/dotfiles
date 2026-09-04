#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

ZSHRC="${HOME}/.zshrc"
NVM_DIR="${HOME}/.nvm"

log "Installing nvm..."

# Install nvm if not present
if [[ ! -d "${NVM_DIR}" ]]; then
  # Resolve latest nvm tag. Try git ls-remote first (no rate limit), fall back
  # to the GitHub API (rate-limited to 60 req/hr unauthenticated).
  NVM_LATEST="$(git ls-remote --tags --refs --sort='version:refname' \
    https://github.com/nvm-sh/nvm.git 'v*' 2>/dev/null \
    | awk -F/ '{print $NF}' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | tail -n 1 || true)"

  if [[ -z "${NVM_LATEST}" ]]; then
    NVM_LATEST="$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r '.tag_name' || true)"
  fi

  if [[ -z "${NVM_LATEST}" || "${NVM_LATEST}" == "null" ]]; then
    log "ERROR: Could not determine latest nvm version"
    return 1
  fi
  log "Installing nvm ${NVM_LATEST}..."
  install_nvm() { curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_LATEST}/install.sh" | bash; }
  run install_nvm
  log "✓ nvm ${NVM_LATEST} installed"
else
  log "✓ nvm already installed"
fi

log "Configuring nvm oh-my-zsh plugin..."

if [[ ! -f "${ZSHRC}" ]]; then
  if dry_run; then
    ui_plan "enable the nvm OMZ plugin and .nvmrc autoload in ~/.zshrc"
    ui_plan "install the current Node LTS, pin it as default, and install default-packages"
    return 0
  fi
  log "ERROR: ${ZSHRC} not found. Install Oh My Zsh first."
  return 1
fi

# Add nvm to plugins list if not present
if grep -Eq '^[[:space:]]*plugins=\([^)]*\bnvm\b' "${ZSHRC}"; then
  log "✓ nvm already in plugins list"
else
  # Add nvm to plugins array
  if grep -Eq '^[[:space:]]*plugins=\(' "${ZSHRC}"; then
    # Insert nvm into existing plugins list (before the closing paren)
    run sed -i '' 's/^[[:space:]]*plugins=(\([^)]*\))/plugins=(\1 nvm)/' "${ZSHRC}"
    log "✓ Added nvm to plugins list"
  else
    log "ERROR: No plugins=() found in ${ZSHRC}"
    return 1
  fi
fi

# Add zstyle directive before source $ZSH/oh-my-zsh.sh if not present.
# `autoload` = switch Node versions automatically on cd into a dir with .nvmrc.
if grep -Fq "zstyle ':omz:plugins:nvm' autoload" "${ZSHRC}"; then
  log "✓ nvm zstyle directive already present"
else
  # Insert zstyle line before the source $ZSH/oh-my-zsh.sh line
  run sed -i '' '/^[[:space:]]*source \$ZSH\/oh-my-zsh.sh/i\
# Auto-switch Node when entering a directory with .nvmrc\
zstyle '"'"':omz:plugins:nvm'"'"' autoload true\
' "${ZSHRC}"
  log "✓ Added nvm zstyle directive"
fi

# The nvm install script appends its own eager `source nvm.sh` block to
# ~/.zshrc. The OMZ nvm plugin already sources nvm.sh (and its completion),
# so that block loads nvm twice and roughly doubles shell startup time.
# Strip it; the plugin is the single owner of nvm initialisation.
if grep -Eq '^\[ -s "\$NVM_DIR/(nvm\.sh|bash_completion)" \]' "${ZSHRC}"; then
  strip_nvm_lines() {
    grep -Ev '^\[ -s "\$NVM_DIR/(nvm\.sh|bash_completion)" \]' "${ZSHRC}" > "${ZSHRC}.tmp"  # dry-run: safe (called via run)
    mv "${ZSHRC}.tmp" "${ZSHRC}"  # dry-run: safe (called via run)
  }
  run strip_nvm_lines
  log "✓ Removed duplicate nvm.sh sourcing from .zshrc (OMZ plugin owns it)"
else
  log "✓ No duplicate nvm.sh sourcing in .zshrc"
fi

# Deploy default-packages (auto-installed with each new Node version)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_PACKAGES="${REPO_ROOT}/dotfiles/nvm/default-packages"
DEST_PACKAGES="${NVM_DIR}/default-packages"

if [[ -f "${SRC_PACKAGES}" ]]; then
  deploy_file "${SRC_PACKAGES}" "${DEST_PACKAGES}"
fi

# Source nvm for this script
export NVM_DIR="${NVM_DIR}"
# shellcheck source=/dev/null
[[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh"

if ! command -v nvm &>/dev/null; then
  log "NOTE: nvm not available in current shell — restart terminal and re-run this installer."
  log "✓ nvm setup complete (Node install deferred)"
  return 0
fi

# Install latest LTS and set as default
log "Installing latest LTS Node.js..."
LTS_VERSION="$(nvm version-remote --lts 2>/dev/null || echo "")"
if [[ -z "${LTS_VERSION}" || "${LTS_VERSION}" == "N/A" ]]; then
  log "ERROR: Could not resolve the current Node LTS version (offline?)"
  return 1
fi

if nvm ls "${LTS_VERSION}" &>/dev/null; then
  log "✓ Node.js LTS (${LTS_VERSION}) already installed"
else
  run nvm install "${LTS_VERSION}"
  log "✓ Node.js LTS (${LTS_VERSION}) installed"
fi

# Pin the default alias to the concrete version rather than the floating
# `lts/*`. The floating alias silently breaks whenever upstream publishes a
# new LTS patch: it resolves to a version that isn't installed, nvm activates
# nothing, and any Homebrew node (pulled in as a dependency of mongosh,
# opencode, etc.) shadows the nvm toolchain and every global npm binary.
# Compare the raw alias target, not `nvm version default`: that resolves the
# alias, so a floating `lts/*` would look "already pinned" whenever it happens
# to point at the installed LTS today.
if [[ "$(cat "${NVM_DIR}/alias/default" 2>/dev/null)" == "${LTS_VERSION}" ]]; then
  log "✓ Default alias already ${LTS_VERSION}"
else
  run nvm alias default "${LTS_VERSION}" >/dev/null
  log "✓ Default alias set to ${LTS_VERSION}"
fi
nvm use default --silent >/dev/null 2>&1 || true  # dry-run: safe (current process only)

if dry_run && ! nvm ls "${LTS_VERSION}" &>/dev/null; then
  ui_plan "install default-packages into ${LTS_VERSION} and enable corepack"
  log "✓ nvm setup complete (dry run)"
  return 0
fi

log "   Node version: $(node --version)"
log "   npm version: $(npm --version)"

# default-packages only fire on `nvm install`. Backfill any that are missing
# from the default version so a list change (or a version installed before
# the file existed) still converges.
if [[ -f "${DEST_PACKAGES}" ]]; then
  log "Ensuring default-packages are installed for ${LTS_VERSION}..."
  INSTALLED_GLOBALS="$(npm ls -g --depth=0 --json 2>/dev/null | jq -r '.dependencies // {} | keys[]' || true)"
  while IFS= read -r pkg || [[ -n "${pkg}" ]]; do
    pkg="${pkg%%#*}"
    pkg="$(echo "${pkg}" | xargs || true)"
    [[ -z "${pkg}" ]] && continue
    if grep -qxF "${pkg}" <<< "${INSTALLED_GLOBALS}"; then
      ui_skip "${pkg}"
    else
      ui_spin "Installing ${pkg}..." npm install -g "${pkg}"
      ui_success "${pkg}"
    fi
  done < "${DEST_PACKAGES}"
fi

# Enable Corepack for native Yarn/pnpm management
NODE_BIN_DIR="$(dirname "$(command -v node)")"
if [[ -x "${NODE_BIN_DIR}/pnpm" && -x "${NODE_BIN_DIR}/yarn" ]]; then
  log "✓ Corepack already enabled"
else
  log "Enabling Corepack..."
  run corepack enable 2>/dev/null || true
  log "✓ Corepack enabled (yarn/pnpm managed natively)"
fi

# Sanity check: the node on PATH must be nvm's, not Homebrew's.
NODE_BIN="$(command -v node || true)"
if [[ "${NODE_BIN}" == "${NVM_DIR}/"* ]]; then
  log "✓ node resolves inside nvm (${NODE_BIN})"
else
  log "NOTE: node resolves to ${NODE_BIN:-nothing}, not nvm. A Homebrew node (dependency of mongosh/opencode) is shadowing it — open a new shell and check 'nvm current'."
fi

log "✓ nvm setup complete"
log "NOTE: Restart your terminal or run: source ~/.zshrc"
