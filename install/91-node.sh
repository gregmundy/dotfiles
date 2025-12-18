#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

ZSHRC="${HOME}/.zshrc"
NVM_DIR="${HOME}/.nvm"

log "Installing nvm..."

# Install nvm if not present
if [[ ! -d "${NVM_DIR}" ]]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  log "✓ nvm installed"
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

# Source nvm for this script
export NVM_DIR="${NVM_DIR}"
# shellcheck source=/dev/null
[[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh"

# Install latest LTS and set as default
log "Installing latest LTS Node.js..."
if command -v nvm &>/dev/null; then
  nvm install --lts
  nvm alias default 'lts/*'
  log "✓ Node.js LTS installed and set as default"
  log "   Node version: $(node --version)"
  log "   npm version: $(npm --version)"
else
  log "ERROR: nvm not available in current shell"
  log "NOTE: Restart your terminal and run: nvm install --lts && nvm alias default 'lts/*'"
  return 0
fi

log "✓ nvm setup complete"
log "NOTE: Restart your terminal or run: source ~/.zshrc"
