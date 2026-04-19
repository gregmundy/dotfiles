# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"

# List files
# Plain `ls` stays BSD for pipeline/script compatibility.
# LSCOLORS: swap default red exec (bx) for bold green (Cx) — readable on dark.
export LSCOLORS="ExFxGxDxCxegedabagacad"
alias ls="ls -G"

# Long/hidden views use eza (icons + git status + dir-first sort).
# Falls back to ls if eza is missing.
if command -v eza &>/dev/null; then
  alias ll="eza -lh --icons --git --group-directories-first"
  alias la="eza -lah --icons --git --group-directories-first"
  alias l="eza --icons --group-directories-first"
  alias lt="eza --tree --icons --level=2 --group-directories-first"
else
  alias ll="ls -lah"
  alias la="ls -la"
  alias l="ls -CF"
fi

# Safety
alias rm="rm -i"
alias mv="mv -i"
alias cp="cp -i"

# Grep with color
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

# Git shortcuts (beyond gitconfig aliases)
alias g="git"
alias gs="git status -sb"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit"
alias gcm="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gco="git checkout"
alias gb="git branch"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log --oneline -20"

# Lazygit / Lazydocker
alias lg="lazygit"
alias lzd="lazydocker"

# Docker
alias d="docker"
alias dc="docker compose"
alias dps="docker ps"
alias dpsa="docker ps -a"
alias dimg="docker images"
alias dex="docker exec -it"
alias dlogs="docker logs -f"

# Development
alias c="code ."
alias cr="cursor ."

# Python/uv
alias py="python3"
alias uvr="uv run"
alias uvs="uv sync"
alias uvi="uv pip install"
alias uve="uv venv && source .venv/bin/activate"

# Quick edits
alias zshrc="$EDITOR ~/.zshrc"
alias reload="source ~/.zshrc"

# System
alias ports="lsof -i -P -n | grep LISTEN"
alias ip="curl -s ifconfig.me"
alias localip="ipconfig getifaddr en0"
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

# OpenTofu (Terraform replacement)
alias terraform="tofu"
alias tf="tofu"

# Misc
alias cls="clear"
alias h="history"
alias path='echo -e ${PATH//:/\\n}'
