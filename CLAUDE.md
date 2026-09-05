# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a macOS dotfiles/machine bootstrap repository. It automates the setup of a new Mac with preferred applications, development tools, and system configurations.

## Running the Setup

```bash
./setup.sh                 # everything, in numeric order
./setup.sh node zsh        # only installers whose name contains "node" or "zsh"
./setup.sh --list          # show which installers would run
./setup.sh --dry-run       # report what would change (installs, file deploys, defaults) without doing it
./setup.sh --clean-backups # delete *.bak.<timestamp> files from earlier runs
```

This runs installer scripts in `install/` in numeric order (00-*, 05-*, 10-*, etc.). Each script is sourced, not executed as a subprocess. Filters match against the file name, so `91`, `node`, and `91-node` all select `install/91-node.sh`.

## Upgrading

`./upgrade.sh` updates what setup installed (setup itself never upgrades). Sections: `brew mas node elixir rust python npm claude codex vscode cleanup` (default) plus `xcode` on request; `--dry-run` and `--greedy`. The node and elixir sections source the corresponding installers, so the "install latest and repin" logic lives in one place. Same `run`/`dry_run` helpers, covered by `tests/lint-side-effects.sh`.

## Uninstalling

`./uninstall.sh` reverses setup. Dry run by default; `--apply` executes after a typed confirmation. Tiers: `--configs --runtimes --apps --packages --defaults --homebrew` (all when none given). Formula, cask, tap, mas, and defaults lists are grepped from `install/*.sh`, so adding a package to an installer automatically adds it to the uninstaller. Config files move to `~/.dotfiles-uninstall-<ts>/`; regenerable trees (nvm, asdf, ...) are deleted; `remove_tree` refuses paths outside `$HOME`. Uses the same `run`/`dry_run` helpers as the installers and is covered by `tests/lint-side-effects.sh`.

## Architecture

### Directory Structure

- `setup.sh` - Main entry point that sources all installers in order
- `upgrade.sh` - Updates everything setup installed (see below)
- `uninstall.sh` - Reverses setup (dry run by default, see below)
- `install/` - Numbered installer scripts (XX-name.sh) run sequentially
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
- `brew_ensure` - Install Homebrew if missing
- `brew_install_formula <name>` - Install formula (idempotent)
- `brew_install_cask <name>` - Install cask (idempotent, no spinner so sudo prompts aren't swallowed)

**run.sh** - Dry-run plumbing. `setup.sh --dry-run` exports `DRY_RUN=1`; every side effect in an installer must go through one of these so a dry run prints instead of acting:
- `run <cmd...>` - Execute, or print "would run" in dry-run. Wrap multi-command steps in a function and `run` the function.
- `deploy_file <src> <dest> [mode]` - Copy a dotfile into place: skip if identical, back up then replace if different, create parent dirs.
- `defaults_write <domain> <key> <-bool|-int|-string> <value>` - Idempotent `defaults write` (reads first, skips if equal).
- `append_line <file> <line>` / `write_file <dest> <content>` - Idempotent file edits.
- `dry_run` - Predicate for steps that need a custom plan message (e.g. interactive prompts).

`tests/lint-side-effects.sh` greps `install/*.sh` for raw side-effecting commands (cp, sed -i, brew install, git clone, ...) that bypass these helpers. Run it after editing an installer. A line that is genuinely read-only or only reachable outside dry-run can be marked `# dry-run: safe`.

**fs.sh** - Filesystem helpers:
- `ensure_dir <path>` - Create directory if missing

**xcodes.sh** - Xcode management via xcodes CLI

**apps.sh** - App bundle helpers:
- `app_installed <Name>` - True if `Name.app` exists in `/Applications` or `~/Applications`

### Installer Naming Convention

Scripts are prefixed with numbers to control execution order:
- 00-09: Bootstrap (Homebrew, build dependencies)
- 10-19: System config (macOS defaults, directories, editorconfig)
- 20-29: Build tools (Xcode, mas)
- 30-39: Terminal & shell (Ghostty, tmux, zsh, direnv)
- 40-49: Window management (Rectangle), git config, SSH, networking/VPN
- 50-59: Browsers
- 60-69: Productivity (apps, CAD/3D, AI tools)
- 70-79: Dev tools (Docker, IDEs, API tools, Claude Code config, database clients)
- 80-89: Mobile development (Watchman, CocoaPods)
- 90-99: Language runtimes (Elixir/Erlang, Node, Python, Go, Rust, Java, OpenTofu)

### Writing New Installers

1. Create `install/XX-name.sh` with appropriate number prefix
2. Add `set -euo pipefail` at top
3. Source bootstrap.sh
4. Use `log` function for all output (prefixes with script name)
5. Use idempotent checks (installers may run multiple times)
6. Route every side effect through `run`, `deploy_file`, `defaults_write`, `append_line`, `write_file`, or the brew helpers so `--dry-run` stays truthful; run `tests/lint-side-effects.sh`
7. Use `return 1` for errors (scripts are sourced, not executed)

### Logging Conventions

Use the `log` function from bootstrap.sh for consistent output:
```bash
log "Installing something..."      # Action in progress
log "✓ Something installed"        # Success
log "ERROR: Something failed"      # Error (followed by return 1)
log "NOTE: Post-install info"      # User instructions
```
