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

# Helper to ask yes/no questions (defaulting to Yes)
ask_yes_no() {
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

# 1. Neovim Config Removal & Backup Restore
NVIM_CONFIG_DIR="$HOME/.config/nvim"
rm -f "$NVIM_CONFIG_DIR/.minimal" 2>/dev/null || true
rm -f "$DOTFILES_DIR/nvim/.minimal" 2>/dev/null || true

if [ -L "$NVIM_CONFIG_DIR" ]; then
  info "Removing Neovim configuration symlink..."
  rm "$NVIM_CONFIG_DIR"
  success "Removed Neovim symlink."
  restore_backup "$NVIM_CONFIG_DIR"
elif [ -d "$NVIM_CONFIG_DIR" ]; then
  if ask_yes_no "Found a non-symlink Neovim config folder at ${NVIM_CONFIG_DIR}. Delete it?"; then
    rm -rf "$NVIM_CONFIG_DIR"
    success "Deleted Neovim config folder."
    restore_backup "$NVIM_CONFIG_DIR"
  fi
fi

# 2. Neovim Plugins, Cache, and State Clean up (Crucial for fresh start)
if ask_yes_no "Delete Neovim local package cache and state directories (highly recommended to start fresh)?"; then
  info "Cleaning Neovim user data/cache directories..."
  rm -rf "$HOME/.local/share/nvim"
  rm -rf "$HOME/.local/state/nvim"
  rm -rf "$HOME/.cache/nvim"
  success "Cleaned Neovim data, state, and cache folders."
fi

# 3. Ghostty Config Removal & Backup Restore
GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
if [ -L "$GHOSTTY_CONFIG_DIR" ]; then
  info "Removing Ghostty configuration symlink..."
  rm "$GHOSTTY_CONFIG_DIR"
  success "Removed Ghostty symlink."
  restore_backup "$GHOSTTY_CONFIG_DIR"
elif [ -d "$GHOSTTY_CONFIG_DIR" ]; then
  if ask_yes_no "Found a non-symlink Ghostty config folder at ${GHOSTTY_CONFIG_DIR}. Delete it?"; then
    rm -rf "$GHOSTTY_CONFIG_DIR"
    success "Deleted Ghostty config folder."
    restore_backup "$GHOSTTY_CONFIG_DIR"
  fi
fi

# 3.5. Yazi Config Removal & Backup Restore
YAZI_CONFIG_DIR="$HOME/.config/yazi"
if [ -L "$YAZI_CONFIG_DIR" ]; then
  info "Removing Yazi configuration symlink..."
  rm "$YAZI_CONFIG_DIR"
  success "Removed Yazi symlink."
  restore_backup "$YAZI_CONFIG_DIR"
elif [ -d "$YAZI_CONFIG_DIR" ]; then
  if ask_yes_no "Found a non-symlink Yazi config folder at ${YAZI_CONFIG_DIR}. Delete it?"; then
    rm -rf "$YAZI_CONFIG_DIR"
    success "Deleted Yazi config folder."
    restore_backup "$YAZI_CONFIG_DIR"
  fi
fi


# 4. Oh My Zsh & Custom Plugins Removal
if ask_yes_no "Do you want to delete Oh My Zsh and its custom plugins (~/.oh-my-zsh)?"; then
  if [ -d "$HOME/.oh-my-zsh" ]; then
    info "Deleting ~/.oh-my-zsh..."
    rm -rf "$HOME/.oh-my-zsh"
    success "Deleted Oh My Zsh directory."
  else
    info "Oh My Zsh directory not found."
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
if ask_yes_no "Do you want to uninstall system packages installed by the dotfiles installer (neovim, starship, zoxide, fzf, ripgrep, fd-find, zsh, unzip, yazi)?"; then
  if [[ "$OS" == "Darwin" ]]; then
    info "Uninstalling dependencies via Homebrew..."
    brew uninstall --force neovim starship zoxide fzf ripgrep fd zsh node unzip yazi ffmpeg sevenzip jq poppler imagemagick || true
  elif [[ "$OS" == "Linux" ]]; then
    if command -v apt-get &> /dev/null; then
      info "Uninstalling dependencies via apt-get..."
      sudo apt-get purge -y neovim starship zoxide fzf ripgrep fd-find zsh unzip ffmpeg jq poppler-utils imagemagick p7zip-full || true
      if command -v snap &> /dev/null; then
        sudo snap remove yazi || true
      fi
      sudo apt-get autoremove -y || true
    elif command -v pacman &> /dev/null; then
      info "Uninstalling dependencies via pacman..."
      sudo pacman -Rns --noconfirm neovim starship zoxide fzf ripgrep fd zsh unzip yazi ffmpeg 7zip jq poppler resvg imagemagick || true
    elif command -v dnf &> /dev/null; then
      info "Uninstalling dependencies via dnf..."
      sudo dnf remove -y neovim starship zoxide fzf ripgrep fd-find zsh unzip yazi ffmpeg 7zip jq poppler imagemagick || true
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
if ask_yes_no "Do you want to delete this dotfiles repository directory ($DOTFILES_DIR)?"; then
  info "Self-deleting dotfiles directory..."
  # Executing deletion in background so the script can finish gracefully
  # or simply running rm -rf which works as the script is loaded in RAM.
  rm -rf "$DOTFILES_DIR"
  success "Dotfiles repository deleted! Uninstallation complete."
else
  success "Uninstallation complete. Dotfiles repository kept at ${DOTFILES_DIR}."
fi
