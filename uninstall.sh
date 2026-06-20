#!/usr/bin/env bash

# ==============================================================================
# Dotfiles Uninstaller & Cleanup Script
# ==============================================================================

# Exit on error (except where handled)
set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Directory paths
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Helper logging functions
info() { echo -e "${BLUE}${BOLD}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}${BOLD}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}${BOLD}[WARNING]${NC} $1"; }
error() { echo -e "${RED}${BOLD}[ERROR]${NC} $1"; }
prompt() { echo -e -n "${CYAN}${BOLD}[?]${NC} $1 "; }

# Parse options
NON_INTERACTIVE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes|--non-interactive)
      NON_INTERACTIVE=true
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  -y, --yes, --non-interactive  Run in non-interactive mode (auto-accept all prompts)"
      echo "  -h, --help                    Show this help message"
      exit 0
      ;;
    *)
      warn "Unknown option: $1"
      shift
      ;;
  esac
done

# Helper to ask yes/no questions (defaulting to Yes)
ask_yes_no() {
  if [[ "$NON_INTERACTIVE" == "true" ]]; then
    return 0
  fi
  local prompt_msg="$1"
  local answer
  while true; do
    prompt "${prompt_msg} [Y/n]:"
    read -r answer
    # If empty, default to Yes
    if [[ -z "$answer" ]]; then
      return 0
    fi
    case "${answer:0:1}" in
      y|Y ) return 0 ;;
      n|N ) return 1 ;;
      * ) info "Please answer yes (y) or no (n)." ;;
    esac
  done
}

# Helper to restore the latest backup found
restore_backup() {
  local target_dir="$1"
  # Find backups matching target_dir.bak.*
  local backups=($(ls -d ${target_dir}.bak.* 2>/dev/null | sort -r || true))
  if [ ${#backups[@]} -gt 0 ]; then
    local latest="${backups[0]}"
    if ask_yes_no "Found configuration backup at ${latest}. Do you want to restore it?"; then
      rm -rf "$target_dir"
      mv "$latest" "$target_dir"
      success "Restored backup to ${target_dir}!"
    else
      info "Keeping ${target_dir} as is (or empty)."
    fi
  fi
}

echo -e "${MAGENTA}${BOLD}"
echo "=========================================="
echo "      CLI & Neovim Dotfiles Uninstaller   "
echo "=========================================="
echo -e "${NC}"
info "Dotfiles directory to remove: ${DOTFILES_DIR}"

if ! ask_yes_no "Are you sure you want to uninstall and remove dotfiles configurations?"; then
  info "Uninstall aborted."
  exit 0
fi

# Detect Operating System
OS="$(uname -s)"

# Helper to unstow and restore backups
unstow_package() {
  local package="$1"
  local target_path="$2"

  # Determine indicator file to check if already symlinked
  local indicator=""
  case "$package" in
    nvim) indicator="init.lua" ;;
    ghostty) indicator="config" ;;
    yazi) indicator="yazi.toml" ;;
    hunk) indicator="config.toml" ;;
  esac

  local indicator_path="${target_path}/${indicator}"

  if [ -L "$indicator_path" ] && [ "$(readlink "$indicator_path")" -ef "$DOTFILES_DIR/$package/$indicator" ]; then
    info "Removing $package configuration symlink using Stow..."
    if command -v stow &> /dev/null; then
      stow -D -d "$DOTFILES_DIR" -t "$target_path" "$package"
      success "Unstowed $package configuration."
    else
      rm -f "$target_path/$indicator"
      success "Removed $package symlink manually."
    fi

    # If the directory is now empty, remove it so we can restore the backup
    if [ -d "$target_path" ] && [ -z "$(ls -A "$target_path" 2>/dev/null)" ]; then
      rmdir "$target_path"
    fi
    restore_backup "$target_path"
  elif [ -d "$target_path" ] || [ -f "$target_path" ]; then
    if ask_yes_no "Found a non-symlink $package config folder at $target_path. Delete it?"; then
      rm -rf "$target_path"
      success "Deleted $package config folder."
      restore_backup "$target_path"
    fi
  fi
}

# 1. Neovim Config Removal & Backup Restore
rm -f "$HOME/.config/nvim/.minimal" 2>/dev/null || true
rm -f "$DOTFILES_DIR/nvim/.minimal" 2>/dev/null || true
unstow_package "nvim" "$HOME/.config/nvim"

# 2. Neovim Plugins, Cache, and State Clean up (Crucial for fresh start)
if ask_yes_no "Delete Neovim local package cache and state directories (highly recommended to start fresh)?"; then
  info "Cleaning Neovim user data/cache directories..."
  rm -rf "$HOME/.local/share/nvim"
  rm -rf "$HOME/.local/state/nvim"
  rm -rf "$HOME/.cache/nvim"
  success "Cleaned Neovim data, state, and cache folders."
fi

# 3. Ghostty Config Removal & Backup Restore
unstow_package "ghostty" "$HOME/.config/ghostty"

# 3.5. Yazi Config Removal & Backup Restore
unstow_package "yazi" "$HOME/.config/yazi"

# 3.7. Hunk Config Removal & Backup Restore
unstow_package "hunk" "$HOME/.config/hunk"


# 4. Oh My Zsh & Custom Plugins Removal
if ask_yes_no "Do you want to delete Oh My Zsh and its custom plugins (~/.oh-my-zsh)?"; then
  if [ -d "$HOME/.oh-my-zsh" ]; then
    info "Deleting ~/.oh-my-zsh..."
    rm -rf "$HOME/.oh-my-zsh"
    success "Deleted Oh My Zsh directory."
  else
    info "Oh My Zsh directory not found."
  fi

  ZSHRC="$HOME/.zshrc"
  if [ -f "$ZSHRC" ]; then
    info "Removing custom plugins from ~/.zshrc plugins list..."
    python3 -c "
import re
path = '$ZSHRC'
try:
    content = open(path).read()
    match = re.search(r'plugins=\(([^)]*)\)', content)
    if match:
        existing = match.group(1).split()
        target = ['zsh-autosuggestions', 'zsh-syntax-highlighting']
        new_list = [x for x in existing if x not in target]
        new_plugins = 'plugins=(' + ' '.join(new_list) + ')'
        content = re.sub(r'plugins=\([^)]*\)', new_plugins, content)
        open(path, 'w').write(content)
        print('SUCCESS')
except Exception as e:
    print('ERROR:', e)
" | grep -q "SUCCESS" && success "Cleaned plugins array in ~/.zshrc." || warn "Failed to clean plugins array in ~/.zshrc."
  fi
fi

# 5. Clean Zsh Custom Integrations in ~/.zshrc
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
  if ask_yes_no "Do you want to remove dotfiles custom configurations block from ~/.zshrc?"; then
    info "Removing dotfiles block from ~/.zshrc..."
    python3 -c "
import re
path = '$ZSHRC'
try:
    content = open(path).read()
    start = '# >>> CUSTOM DOTFILES CONFIGURATION >>>'
    end = '# <<< CUSTOM DOTFILES CONFIGURATION <<<'
    pattern = re.escape(start) + r'.*?' + re.escape(end)
    new_content = re.sub(pattern, '', content, flags=re.DOTALL)
    # Clean up excessive newlines
    new_content = re.sub(r'\n{3,}', '\n\n', new_content)
    open(path, 'w').write(new_content)
    print('SUCCESS')
except Exception as e:
    print('ERROR:', e)
" | grep -q "SUCCESS" && success "Cleaned ~/.zshrc." || error "Failed to automatically edit ~/.zshrc."
  fi
fi

# 6. Remove fd symlink if created
FD_SYMLINK="$HOME/.local/bin/fd"
if [ -L "$FD_SYMLINK" ]; then
  info "Removing fd symlink..."
  rm "$FD_SYMLINK"
  success "Removed fd symlink."
fi

# 6.5. Remove standalone Node.js if installed
if [ -d "$HOME/.local/lib/nodejs" ]; then
  if ask_yes_no "Do you want to delete the standalone Node.js installation (~/.local/lib/nodejs)?"; then
    info "Removing standalone Node.js..."
    rm -rf "$HOME/.local/lib/nodejs"
    rm -f "$HOME/.local/bin/node"
    rm -f "$HOME/.local/bin/npm"
    rm -f "$HOME/.local/bin/npx"
    success "Removed standalone Node.js."
  fi
fi

# 7. Package Uninstallation
if ask_yes_no "Do you want to uninstall system packages installed by the dotfiles installer (neovim, starship, zoxide, fzf, ripgrep, fd-find, zsh, yazi, ghostty, stow)?"; then
  if [[ "$OS" == "Darwin" ]]; then
    info "Uninstalling dependencies via Homebrew..."
    brew uninstall --force neovim starship zoxide fzf ripgrep fd zsh unzip yazi ffmpeg sevenzip jq poppler imagemagick stow || true
    info "Uninstalling Ghostty via Homebrew Cask..."
    brew uninstall --cask --force ghostty || true
  elif [[ "$OS" == "Linux" ]]; then
    if command -v apt-get &> /dev/null; then
      info "Uninstalling dependencies via apt-get..."
      sudo apt-get purge -y neovim starship zoxide fzf ripgrep fd-find zsh unzip ffmpeg jq poppler-utils imagemagick p7zip-full stow || true
      if command -v snap &> /dev/null; then
        sudo snap remove yazi || true
      fi
      sudo apt-get autoremove -y || true
    elif command -v pacman &> /dev/null; then
      info "Uninstalling dependencies via pacman..."
      sudo pacman -Rns --noconfirm neovim starship zoxide fzf ripgrep fd zsh unzip yazi ffmpeg 7zip jq poppler resvg imagemagick stow || true
    elif command -v dnf &> /dev/null; then
      info "Uninstalling dependencies via dnf..."
      sudo dnf remove -y neovim starship zoxide fzf ripgrep fd-find zsh unzip yazi ffmpeg 7zip jq poppler imagemagick stow || true
    else
      warn "No supported package manager found to uninstall dependencies."
    fi
  fi
  success "Uninstalled package dependencies!"
fi

# 8. Self-destruction of the dotfiles repository
echo -e "\n${RED}${BOLD}=========================================="
echo "          Self-Deletes Dotfiles           "
echo "=========================================="
echo -e "${NC}"
if [[ "$NON_INTERACTIVE" == "true" ]]; then
  info "Non-interactive mode active. Skipping self-deletion of dotfiles directory."
else
  if ask_yes_no "Do you want to delete this dotfiles repository directory ($DOTFILES_DIR)?"; then
    info "Self-deleting dotfiles directory..."
    # Executing deletion in background so the script can finish gracefully
    # or simply running rm -rf which works as the script is loaded in RAM.
    rm -rf "$DOTFILES_DIR"
    success "Dotfiles repository deleted! Uninstallation complete."
  else
    success "Uninstallation complete. Dotfiles repository kept at ${DOTFILES_DIR}."
  fi
fi
