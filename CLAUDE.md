# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS dotfiles/machine bootstrap repository. It automates the setup of a new Mac with preferred applications, development tools, and system configurations.

## Running the Setup

```bash
./setup.sh                 # everything, in numeric order
./setup.sh node zsh        # only installers whose name contains "node" or "zsh"
./setup.sh --list          # show which installers would run
./setup.sh --clean-backups # delete *.bak.<timestamp> files from earlier runs
```

This runs installer scripts in `install/` in numeric order (00-*, 05-*, 10-*, etc.). Each script is sourced, not executed as a subprocess. Filters match against the file name, so `91`, `node`, and `91-node` all select `install/91-node.sh`.

## Architecture

### Directory Structure

- `setup.sh` - Main entry point that sources all installers in order
- `Brewfile` - Single source of truth for everything Homebrew can install: taps, formulae, casks, Mac App Store apps, VS Code extensions, Go tools. Applied by `install/05-brewfile.sh` via `brew bundle`.
- `install/` - Numbered installer scripts (XX-name.sh) run sequentially. These handle what a Brewfile cannot: macOS defaults, dotfile deployment, shell/runtime setup, Xcode selection.
- `lib/` - Shared helper functions sourced by installers
- `dotfiles/` - Config files deployed to `$HOME` by installers
- `templates/` - Reference templates (e.g. `docker-compose/`) not auto-deployed

### Library Functions (lib/)

**bootstrap.sh** - Standard bootstrap for installers. Sources `ui.sh`, `brew.sh`, `fs.sh`, `xcodes.sh` and defines `log()`, which dispatches messages to the right `ui_*` helper based on prefix (`✓`, `ERROR:`, `NOTE:`). Installer scripts should source this first:
```bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"
```

**ui.sh** - Gum-powered UI helpers (falls back to plain text if `gum` is missing). Provides section headers, step/success/skip/error styling, spinners (`ui_spin`, `ui_spin_download`, `ui_spin_config`, `ui_spin_build`), styled input (`ui_input`), deferred post-install notes (`ui_defer_note` + `ui_show_notes`), and the welcome/completion banners. `log()` routes through these — call `ui_*` directly only when you need styling `log()` doesn't cover.

**brew.sh** - Homebrew helpers:
- `brew_ensure` - Install Homebrew if missing (and re-validate sudo afterwards)
- `brew_ensure_clt` - Install the Command Line Tools if missing
- `brew_install_formula` / `brew_install_cask` / `brew_tap_trusted` - Ad-hoc helpers; prefer adding to `Brewfile`

**fs.sh** - Filesystem helpers:
- `ensure_dir <path>` - Create directory if missing

**xcodes.sh** - Xcode management via xcodes CLI

**apps.sh** - App bundle helpers:
- `app_installed <Name>` - True if `Name.app` exists in `/Applications` or `~/Applications`

### Installer Naming Convention

Scripts are prefixed with numbers to control execution order:
- 00-09: Bootstrap (Command Line Tools, Homebrew, Brewfile)
- 10-19: System config (macOS defaults, directories, editorconfig)
- 20-29: Xcode install/selection
- 30-39: Terminal & shell config (Ghostty, vim/nvim, tmux, zsh, starship, direnv plugin)
- 40-49: Git config, git-lfs hooks, SSH config
- 70-79: Docker login item, Claude Code, VS Code settings, Claude Code config
- 90-99: Language runtimes (Elixir/Erlang via asdf, Node via nvm, Python via uv, Rust via rustup)

Everything installable by Homebrew (including casks, `mas` apps, VS Code extensions, and Go tools) belongs in `Brewfile`, not in an installer.

### Adding Software

Add a line to `Brewfile` (`brew`, `cask`, `mas`, `vscode`, or `go`). Only write an installer when the step is not something Homebrew Bundle can express (config deployment, defaults, runtime version setup).

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
