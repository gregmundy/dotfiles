# Tool initializations
# Loaded after aliases and functions

# zoxide - smarter cd
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# fzf - Ctrl-R history, Ctrl-T file picker, Alt-C directory jump
if command -v fzf &>/dev/null; then
  for _fzf_prefix in /opt/homebrew/opt/fzf /usr/local/opt/fzf; do
    if [[ -f "$_fzf_prefix/shell/key-bindings.zsh" ]]; then
      source "$_fzf_prefix/shell/key-bindings.zsh"
      source "$_fzf_prefix/shell/completion.zsh"
      break
    fi
  done
  unset _fzf_prefix
fi

# Starship prompt
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
