# Make directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.tar.xz)    tar xJf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Quick find file by name
ff() {
  find . -name "*$1*" 2>/dev/null
}

# Quick find and grep
fgr() {
  grep -r "$1" . --include="*.$2" 2>/dev/null
}

# Create a .gitignore from gitignore.io
gi() {
  curl -sL "https://www.toptal.com/developers/gitignore/api/$@"
}

# Quick HTTP server
serve() {
  local port="${1:-8000}"
  python3 -m http.server "$port"
}

# JSON pretty print
json() {
  if [ -p /dev/stdin ]; then
    python3 -m json.tool
  elif [ -f "$1" ]; then
    python3 -m json.tool "$1"
  else
    echo "$1" | python3 -m json.tool
  fi
}

# Get size of directory
dirsize() {
  du -sh "${1:-.}" 2>/dev/null
}

# Kill process on port
killport() {
  lsof -ti:"$1" | xargs kill -9 2>/dev/null || echo "No process on port $1"
}

# Docker cleanup
docker-cleanup() {
  echo "Removing stopped containers..."
  docker container prune -f
  echo "Removing unused images..."
  docker image prune -f
  echo "Removing unused volumes..."
  docker volume prune -f
  echo "Done!"
}
