# Brewfile — single source of truth for everything Homebrew can install:
# taps, formulae, casks, Mac App Store apps, VS Code extensions, Go tools.
#
# Applied by install/05-brewfile.sh via `brew bundle install --no-upgrade`.
# Idempotent: installed entries are skipped. Casks are installed with --adopt
# so apps that were installed by hand are taken over rather than duplicated.
#
# Check drift on a machine:   brew bundle check --file Brewfile --verbose
# See what's installed extra: brew bundle cleanup --file Brewfile   (dry run)

# ── Taps ─────────────────────────────────────────────────────────────
# Homebrew requires non-official taps to be explicitly trusted.
tap "gregmundy/tap", trusted: true   # llamavm, llamactl
tap "supabase/tap",  trusted: true   # supabase CLI

# ── Bootstrap: setup UI + build dependencies ─────────────────────────
brew "gum"        # styled setup output (lib/ui.sh falls back to plain text without it)
brew "jq"
brew "aria2"      # faster Xcode downloads via xcodes
brew "autoconf"
brew "cmake"
brew "openssl"
brew "wxwidgets"  # Erlang observer
brew "libxslt"
brew "fop"        # Erlang docs

# ── CLI tools ────────────────────────────────────────────────────────
brew "yq"
brew "fzf"
brew "ripgrep"
brew "fd"         # fzf's Ctrl-T / Alt-C use it automatically
brew "bat"
brew "eza"
brew "gh"
brew "btop"
brew "biome"
brew "shellcheck"
brew "lazygit"
brew "lazydocker"
brew "zoxide"
brew "tldr"
brew "httpie"
brew "git-delta"
brew "poppler"    # pdftotext, pdfimages
brew "jless"
brew "starship"
cask "font-jetbrains-mono-nerd-font"

# ── Build tools ──────────────────────────────────────────────────────
brew "xcodes"     # Xcode itself is handled by install/20-xcode.sh
brew "mas"

# ── Terminal & shell ─────────────────────────────────────────────────
cask "ghostty"
brew "neovim"
brew "tmux"
brew "direnv"

# ── Window management, git, SSH, networking ──────────────────────────
cask "rectangle"
brew "git-lfs"
cask "1password"
cask "1password-cli"
cask "tailscale-app"   # .pkg — needs the sudo session setup.sh caches
cask "protonvpn"

# ── Browsers ─────────────────────────────────────────────────────────
cask "google-chrome"
cask "duckduckgo"

# ── Productivity & communication ─────────────────────────────────────
cask "raycast"
cask "obsidian"
cask "notion"
cask "spotify"
cask "slack"
cask "todoist-app"
cask "appcleaner"
cask "linear"
cask "figma"
cask "steam"
cask "discord"
cask "zoom"

# ── CAD / 3D printing ────────────────────────────────────────────────
cask "bambu-studio"
cask "autodesk-fusion"   # self-updates into ~/Applications; Autodesk sign-in on first launch

# ── AI tools ─────────────────────────────────────────────────────────
cask "chatgpt"
cask "codex-app"   # Codex desktop app (the `codex` CLI comes from npm, see dotfiles/nvm/default-packages).
                   # Deprecated upstream; Homebrew disables it 2027-07-12 — drop this line then.
cask "claude"
cask "lm-studio"
cask "ollama-app"
cask "gregmundy/tap/llamavm"    # nvm-style version manager for source-built llama.cpp
cask "gregmundy/tap/llamactl"   # supervisor / model manager for llama.cpp servers

# ── Dev tools: containers, IDEs, API clients, databases ──────────────
cask "docker-desktop"           # login item handled by install/70-docker.sh
cask "pycharm"
cask "visual-studio-code"
cask "cursor"
cask "cursor-cli"
brew "opencode"
cask "postman"
cask "insomnia"
cask "ngrok"                    # needs: ngrok config add-authtoken <token>
cask "dbeaver-community"
brew "libpq"                    # keg-only psql/pg_dump; dotfiles/zsh/path.zsh adds its bin dir
cask "nosqlbooster-for-mongodb"
brew "mongodb-atlas-cli"
cask "redis-insight"
brew "supabase/tap/supabase"

# ── Mobile development ───────────────────────────────────────────────
brew "watchman"
brew "cocoapods"
brew "xcodegen"

# ── Language runtimes (managers; versions are set up by install/9x-*.sh) ──
brew "asdf"        # Erlang / Elixir
brew "uv"          # Python
brew "go"
brew "goreleaser"
brew "rustup"
cask "temurin"     # Java (Eclipse Temurin)
brew "opentofu"

# Go tooling, installed with `go install` so it tracks the Go toolchain.
go "golang.org/x/tools/gopls"
go "honnef.co/go/tools/cmd/staticcheck"

# ── Mac App Store (requires a signed-in Apple Account in App Store.app) ──
mas "Developer",  id: 640199958
mas "TestFlight", id: 899247664

# ── VS Code extensions ───────────────────────────────────────────────
# Formatters referenced as defaultFormatter in dotfiles/vscode/settings.json
vscode "esbenp.prettier-vscode"
vscode "ms-python.python"
vscode "ms-python.black-formatter"
# Languages / frameworks
vscode "astro-build.astro-vscode"
vscode "golang.go"
# Containers & remote development
vscode "ms-azuretools.vscode-containers"
vscode "ms-vscode-remote.remote-containers"
# Data
vscode "mechatroner.rainbow-csv"
