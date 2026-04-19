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
    NVM_LATEST="$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest | jq -r '.tag_name')"
  fi

  if [[ -z "${NVM_LATEST}" || "${NVM_LATEST}" == "null" ]]; then
    log "ERROR: Could not determine latest nvm version"
    return 1
  fi
  log "Installing nvm ${NVM_LATEST}..."
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_LATEST}/install.sh" | bash
  log "✓ nvm ${NVM_LATEST} installed"
else
  log "✓ nvm already installed"
fi

log "Configuring nvm oh-my-zsh plugin..."

if [[ ! -f "${ZSHRC}" ]]; then
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
    sed -i '' 's/^[[:space:]]*plugins=(\([^)]*\))/plugins=(\1 nvm)/' "${ZSHRC}"
    log "✓ Added nvm to plugins list"
  else
    log "ERROR: No plugins=() found in ${ZSHRC}"
    return 1
  fi
fi

# Add zstyle directive before source $ZSH/oh-my-zsh.sh if not present
if grep -Fq "zstyle ':omz:plugins:nvm' autoload" "${ZSHRC}"; then
  log "✓ nvm zstyle directive already present"
else
  # Insert zstyle line before the source $ZSH/oh-my-zsh.sh line
  sed -i '' '/^[[:space:]]*source \$ZSH\/oh-my-zsh.sh/i\
# nvm: autoload to avoid slow shell startup\
zstyle '"'"':omz:plugins:nvm'"'"' autoload true\
' "${ZSHRC}"
  log "✓ Added nvm zstyle directive"
fi

# Deploy default-packages (auto-installed with each new Node version)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_PACKAGES="${REPO_ROOT}/dotfiles/nvm/default-packages"
DEST_PACKAGES="${NVM_DIR}/default-packages"

if [[ -f "${SRC_PACKAGES}" ]]; then
  if [[ -f "${DEST_PACKAGES}" ]] && cmp -s "${SRC_PACKAGES}" "${DEST_PACKAGES}"; then
    log "✓ default-packages already up to date"
  else
    cp -a "${SRC_PACKAGES}" "${DEST_PACKAGES}"
    log "✓ Installed default-packages"
  fi
fi

# Source nvm for this script
export NVM_DIR="${NVM_DIR}"
# shellcheck source=/dev/null
[[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh"

# Install latest LTS and set as default
log "Installing latest LTS Node.js..."
if command -v nvm &>/dev/null; then
  # Check if LTS is already installed
  LTS_VERSION=$(nvm version-remote --lts 2>/dev/null || echo "")
  if [[ -n "$LTS_VERSION" ]] && nvm ls "$LTS_VERSION" &>/dev/null; then
    log "✓ Node.js LTS ($LTS_VERSION) already installed"
  else
    nvm install --lts
    log "✓ Node.js LTS installed"
  fi

  # Ensure default is set to LTS
  nvm alias default 'lts/*' &>/dev/null
  log "✓ Default set to LTS"
  log "   Node version: $(node --version)"
  log "   npm version: $(npm --version)"

  # Enable Corepack for native Yarn/pnpm management
  log "Enabling Corepack..."
  corepack enable 2>/dev/null || true
  log "✓ Corepack enabled (yarn/pnpm managed natively)"
else
  log "NOTE: nvm not available in current shell — restart terminal and run: nvm install --lts && nvm alias default 'lts/*'"
fi

log "✓ nvm setup complete"
log "NOTE: Restart your terminal or run: source ~/.zshrc"
