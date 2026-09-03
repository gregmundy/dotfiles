#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"

log "Installing database clients..."

# SQL databases
brew_install_cask dbeaver-community

# Postgres client libraries and CLI tools (psql, pg_dump).
# Keg-only: Homebrew does not symlink these into /opt/homebrew/bin.
brew_install_formula libpq

# MongoDB
brew_install_cask nosqlbooster-for-mongodb
brew_install_formula mongodb-atlas-cli

# Redis
brew_install_cask redis-insight

# Supabase CLI (Postgres-backed BaaS) — lives in a third-party tap
brew tap supabase/tap >/dev/null 2>&1 || true
brew_install_formula supabase/tap/supabase

log "✓ Database clients installed"
log "NOTE: libpq is keg-only. dotfiles/zsh/path.zsh adds its bin dir so psql/pg_dump resolve."
