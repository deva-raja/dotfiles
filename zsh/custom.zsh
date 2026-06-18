# ==============================================================================
# Custom Zsh Configurations, Keybindings, & Aliases
# ==============================================================================

# Ensure local bin directories are in PATH
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Quick editor opens & aliases
export EDITOR="nvim"
alias v="nvim"
alias p="pnpm"
alias pw="playwright-cli"
alias cc="claude"

# Integrate zoxide (smarter cd command)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# Integrate Starship prompt
if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

# Integrate fzf (fuzzy finder)
if command -v fzf &> /dev/null; then
  source <(fzf --zsh)
  
  # Load custom fzf-git bindings if present in home directory
  if [ -f "$HOME/fzf-git.sh" ]; then
    source "$HOME/fzf-git.sh"
  fi

fi

# Accept zsh-autosuggestions word-by-word with Ctrl + Space
# Note: Zsh-autosuggestions plugin must be loaded first (e.g. by Oh My Zsh)
bindkey '^ ' forward-word

# Yazi wrapper function to change directory on exit
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  command rm -f -- "$tmp"
}

# Open Yazi with 2 tabs: Tab 1 in ~/Downloads and Tab 2 in current path
function yc() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  YAZI_2ND_TAB="$PWD" command yazi "$HOME/Downloads" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  command rm -f -- "$tmp"
}

