# ==============================================================================
# Custom Zsh Configurations, Keybindings, & Aliases
# ==============================================================================

# Quick editor opens & aliases
alias v="nvim"
alias p="pnpm"

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

  # Integrate 'z' navigation with fzf
  if [ -f "/opt/homebrew/etc/profile.d/z.sh" ]; then
    . /opt/homebrew/etc/profile.d/z.sh
    unalias z 2> /dev/null
    z() {
      local dir
      dir=$(
        _z 2>&1 | fzf --height 40% --layout reverse --info inline --nth 2.. --tac --no-sort --query "$*" --accept-nth 2..
      ) && cd "$dir"
    }
  fi
fi

# Accept zsh-autosuggestions word-by-word with Ctrl + Space
# Note: Zsh-autosuggestions plugin must be loaded first (e.g. by Oh My Zsh)
bindkey '^ ' forward-word
