# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS dotfiles/machine bootstrap repository. It automates the setup of a new Mac with preferred applications, development tools, and system configurations.

## Running the Setup

```bash
./setup.sh
```

This runs all installer scripts in `install/` in numeric order (00-*, 05-*, 10-*, etc.). Each script is sourced, not executed as a subprocess.

## Architecture

### Directory Structure

- `setup.sh` - Main entry point that sources all installers in order
- `install/` - Numbered installer scripts (XX-name.sh) run sequentially
- `lib/` - Shared helper functions sourced by installers

### Library Functions (lib/)

**bootstrap.sh** - Standard bootstrap for installers. Sources all other libs and provides `log()`. Installer scripts should source this first:
```bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"
```

**brew.sh** - Homebrew helpers:
- `brew_ensure` - Install Homebrew if missing
- `brew_install_formula <name>` - Install formula (idempotent)
- `brew_install_cask <name>` - Install cask (idempotent)

**fs.sh** - Filesystem helpers:
- `ensure_dir <path>` - Create directory if missing

**xcodes.sh** - Xcode management via xcodes CLI

### Installer Naming Convention

Scripts are prefixed with numbers to control execution order:
- 00-09: Bootstrap (Homebrew, build dependencies)
- 10-19: System config (macOS defaults, directories)
- 20-29: Build tools (Xcode, mas)
- 30-39: Terminal & shell (Ghostty, zsh, direnv)
- 40-49: Window management (AeroSpace)
- 50-59: Browsers
- 60-69: Productivity (apps, AI tools)
- 70-79: Dev tools (Docker, IDEs)
- 90-99: Language runtimes (Elixir/Erlang)

### Writing New Installers

1. Create `install/XX-name.sh` with appropriate number prefix
2. Add `set -euo pipefail` at top
3. Source bootstrap.sh
4. Use `log` function for all output (prefixes with script name)
5. Use idempotent checks (installers may run multiple times)
6. Use `return 1` for errors (scripts are sourced, not executed)

### Logging Conventions

Use the `log` function from bootstrap.sh for consistent output:
```bash
log "Installing something..."      # Action in progress
log "✓ Something installed"        # Success
log "ERROR: Something failed"      # Error (followed by return 1)
log "NOTE: Post-install info"      # User instructions
```
