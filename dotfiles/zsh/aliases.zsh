# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"

# List files
alias ls="ls -G"
alias ll="ls -lah"
alias la="ls -la"
alias l="ls -CF"

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
alias py="python3"
alias pip="pip3"

# Quick edits
alias zshrc="$EDITOR ~/.zshrc"
alias reload="source ~/.zshrc"

# System
alias ports="lsof -i -P -n | grep LISTEN"
alias ip="curl -s ifconfig.me"
alias localip="ipconfig getifaddr en0"
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"

# Misc
alias cls="clear"
alias h="history"
alias path='echo -e ${PATH//:/\\n}'
