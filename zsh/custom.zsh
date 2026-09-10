# ==============================================================================
# Custom Zsh Configurations, Keybindings, & Aliases
# ==============================================================================

# Ensure local bin directories are in PATH
export PATH="$HOME/.local/bin:$HOME/bin:$HOME/go/bin:$PATH"

# Quick editor opens & aliases
export EDITOR="nvim"
alias v="nvim"
alias p="pnpm"
alias cc="claude"
alias hd="herdr"

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

# Word-by-word navigation with Option + Left/Right Arrow (Alt + Left/Right Arrow) in Ghostty
bindkey "^[[1;3D" backward-word
bindkey "^[[1;3C" forward-word


# Yazi wrapper function to change directory on exit
function yf() {
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

# Find and kill the process(es) listening on a specified port
freeport() {
  if [[ -z "$1" ]]; then
    echo "Usage: freeport <port>"
    return 1
  fi
  local port="$1"
  local pids
  pids=($(lsof -t -i :"$port"))
  
  if [[ ${#pids[@]} -gt 0 ]]; then
    echo "Killing process(es) on port $port (PID: ${pids[*]})..."
    kill -9 "${pids[@]}"
  else
    echo "No process found running on port $port."
  fi
}
alias free=freeport

# Read last AI assistant reply (Claude Code or Antigravity) in the current terminal, or any markdown file
read() {
  # If standard builtin options (e.g. -r, -p, -k, -q, -u, -t, -A, -d, etc.) are passed
  if [[ "$1" =~ ^(-r|-p|-k|-q|-u|-t|-A|-d|-e|-E|-z)$ ]]; then
    builtin read "$@"
    return $?
  fi

  # Piped input (e.g. echo "x" | read var) when not a file or custom flags
  if [[ ! -t 0 ]] && [[ $# -gt 0 ]] && [[ ! -f "$1" ]] && [[ ! "$1" =~ ^(-a|--agent|-n|--last|-o|--offset|-h|-H|-s|--history|--help)$ ]]; then
    builtin read "$@"
    return $?
  fi

  # Assistant keywords, numbers (offsets), files, history flags, or zero arguments
  if [[ $# -eq 0 ]] || [[ -f "$1" ]] || [[ "$1" =~ ^(-a|--agent|-n|--last|-o|--offset|-h|-H|-s|--history|--sessions|--help|agy|antigravity|gemini|cc|claude|claude-code|[0-9]+)$ ]]; then
    "$HOME/.claude/scripts/read-cli.sh" "$@"
    return $?
  fi

  # Fallback to standard builtin read (e.g. read myvar)
  builtin read "$@"
}
