# macOS Dotfiles

A comprehensive macOS machine bootstrap and dotfiles manager. Run one command to set up a new Mac with all preferred applications, development tools, and configurations.

## Quick Start

```bash
git clone https://github.com/yourusername/dotfiles.git ~/Development/dotfiles
cd ~/Development/dotfiles
./setup.sh
```

You'll be prompted for your sudo password once at the start. The setup is fully idempotent—run it again anytime to update or restore your configuration.

---

## What's Included

### Development Tools

| Category | Tools |
|----------|-------|
| **Languages** | Node.js (nvm), Python (uv), Go, Elixir/Erlang |
| **Editors** | VS Code, Neovim, Vim |
| **Containers** | Docker, Colima |
| **API Testing** | Postman, Insomnia |
| **Database** | DBeaver, NoSQLBooster, MongoDB Atlas CLI |
| **Version Control** | Git, Git LFS, GitHub CLI |

### CLI Tools

```
jq        JSON processor           fzf       Fuzzy finder
yq        YAML processor           ripgrep   Fast grep
bat       Better cat               eza       Modern ls
gh        GitHub CLI               btop      System monitor
```

### Applications

| Category | Apps |
|----------|------|
| **Productivity** | Raycast, Obsidian, Notion, Todoist, AppCleaner |
| **Communication** | Slack, Discord, Zoom |
| **Browsers** | Chrome, Firefox |
| **AI** | Claude, ChatGPT, Cursor |
| **Media** | Spotify, IINA |
| **Security** | 1Password, 1Password CLI |
| **Entertainment** | Steam |

### System Configuration

- **Terminal**: Ghostty with Gruvbox Dark theme
- **Shell**: Zsh with Oh My Zsh, custom aliases and functions
- **Window Manager**: AeroSpace (tiling window manager)
- **macOS Defaults**: Optimized Finder, Dock, keyboard settings

---

## Dotfiles Managed

```
dotfiles/
├── aerospace/       # Tiling window manager config
├── ghostty/         # Terminal emulator config
├── git/             # gitconfig, gitignore_global
├── nvim/            # Neovim configuration (init.lua)
├── nvm/             # Default npm packages for new Node versions
├── ssh/             # SSH config (1Password agent)
├── vim/             # Vim configuration (.vimrc)
├── vscode/          # VS Code settings and keybindings
└── zsh/             # Aliases, functions, PATH additions
```

---

## Architecture

### Installer Scripts

Scripts in `install/` run in numeric order:

| Range | Category |
|-------|----------|
| `00-09` | Bootstrap (Homebrew, CLI tools) |
| `10-19` | System configuration (macOS defaults) |
| `20-29` | Build tools (Xcode, mas) |
| `30-39` | Terminal & shell (Ghostty, Zsh, Neovim) |
| `40-49` | Window management, Git, SSH |
| `50-59` | Browsers |
| `60-69` | Productivity & communication |
| `70-79` | Dev tools (Docker, IDEs, databases) |
| `90-99` | Language runtimes |

### Library Functions

Helper functions in `lib/` are sourced by installers:

- **bootstrap.sh** — Standard bootstrap, provides `log()` function
- **brew.sh** — `brew_install_formula`, `brew_install_cask`
- **fs.sh** — `ensure_dir`
- **xcodes.sh** — Xcode version management

---

## Post-Install Setup

Some tools require manual configuration after install:

### 1Password SSH Agent
Enable in 1Password: **Settings → Developer → SSH Agent**

### Git Identity
The installer prompts for your name and email, stored in `~/.gitconfig.local` (not committed).

### App Store Apps
Sign into the App Store before running setup. The installer uses `mas` to install Apple Developer and TestFlight.

---

## Customization

### Adding a New Installer

1. Create `install/XX-name.sh` with appropriate number prefix
2. Add standard header:
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib/bootstrap.sh"
   ```
3. Use `log` for all output
4. Use `brew_install_formula` or `brew_install_cask`
5. Make idempotent (check before installing)

### Adding Dotfiles

1. Add config files to `dotfiles/appname/`
2. Create an installer to symlink or copy them
3. Use `cmp -s` to check if files are already up to date

---

## License

MIT
