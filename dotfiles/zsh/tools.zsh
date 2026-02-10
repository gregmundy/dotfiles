# Tool initializations
# Loaded after aliases and functions

# zoxide - smarter cd
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# Starship prompt
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
