#!/usr/bin/env bash

# ==============================================================================
# Dotfiles Installer & Bootstrapper
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
BACKUP_SUFFIX=".bak.$(date +%F-%H%M%S)"

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

# Helper to install Node.js standalone on Linux if not present
install_node_linux() {
  if command -v node &> /dev/null && command -v npm &> /dev/null; then
    info "Node.js is already installed system-wide ($(node -v)). Skipping standalone installation."
    return 0
  fi

  info "Installing Node.js standalone precompiled binary..."
  local ARCH
  ARCH="$(uname -m)"
  local NODE_ARCH
  case "$ARCH" in
    x86_64) NODE_ARCH="x64" ;;
    aarch64|arm64) NODE_ARCH="arm64" ;;
    *)
      warn "Unsupported architecture for Node.js precompiled binary: $ARCH. Skipping standalone install."
      return 1
      ;;
  esac

  local NODE_VER="v20.12.2"
  local NODE_DIST="node-${NODE_VER}-linux-${NODE_ARCH}"
  local TARBALL="${NODE_DIST}.tar.xz"
  local DOWNLOAD_URL="https://nodejs.org/dist/${NODE_VER}/${TARBALL}"
  local INSTALL_DIR="$HOME/.local/lib/nodejs"
  local BIN_DIR="$HOME/.local/bin"

  info "Downloading Node.js ${NODE_VER} for ${NODE_ARCH}..."
  mkdir -p "$INSTALL_DIR"
  mkdir -p "$BIN_DIR"
  
  if curl -fsSL "$DOWNLOAD_URL" -o "/tmp/${TARBALL}"; then
    info "Extracting Node.js..."
    tar -xJf "/tmp/${TARBALL}" -C "$INSTALL_DIR"
    rm "/tmp/${TARBALL}"
    
    # Symlink binaries to ~/.local/bin
    ln -sfn "$INSTALL_DIR/${NODE_DIST}/bin/node" "$BIN_DIR/node"
    ln -sfn "$INSTALL_DIR/${NODE_DIST}/bin/npm" "$BIN_DIR/npm"
    ln -sfn "$INSTALL_DIR/${NODE_DIST}/bin/npx" "$BIN_DIR/npx"
    
    success "Node.js and npm installed successfully in ~/.local/bin!"
    return 0
  else
    warn "Failed to download precompiled Node.js."
    return 1
  fi
}

# Helper to prompt the user for Node.js installation method if missing
install_node_choice() {
  if command -v node &> /dev/null && command -v npm &> /dev/null; then
    info "Node.js is already installed ($(node -v)). Skipping standalone installation."
    return 0
  fi

  echo -e "\n[?] Node.js/NPM is required by Neovim for web language servers (JS/TS, HTML, CSS, JSON)."
  echo "    How would you like to install Node.js?"
  echo "    1) Standalone User-space (Fastest, zero system bloat, installs in ~/.local/lib/nodejs) [Recommended]"
  echo "    2) System Package Manager (Global, requires sudo/apt-get, installs system-wide packages)"
  echo "    3) Skip (Skip Node installation; some Neovim LSPs will not function until Node is installed)"
  
  local choice
  while true; do
    prompt "Enter your choice [1-3] (default 1):"
    read -r choice
    if [[ -z "$choice" ]]; then
      choice=1
    fi
    case "$choice" in
      1)
        install_node_linux
        return 0
        ;;
      2)
        info "Installing Node.js via system package manager..."
        if command -v apt-get &> /dev/null; then
          sudo apt-get install -y nodejs npm
        elif command -v pacman &> /dev/null; then
          sudo pacman -Syu --needed nodejs npm
        elif command -v dnf &> /dev/null; then
          sudo dnf install -y nodejs npm
        fi
        return 0
        ;;
      3)
        info "Skipping Node.js installation."
        return 0
        ;;
      *)
        info "Invalid choice. Please enter 1, 2, or 3."
        ;;
    esac
  done
}

echo -e "${MAGENTA}${BOLD}"
echo "=========================================="
echo "      CLI & Neovim Dotfiles Installer     "
echo "=========================================="
echo -e "${NC}"
info "Dotfiles directory: ${DOTFILES_DIR}"

# 1. Detect Operating System & Headless Environment
OS="$(uname -s)"
HEADLESS=false
if [[ "$OS" == "Linux" ]] && [[ -z "$DISPLAY" ]] && [[ -z "$WAYLAND_DISPLAY" ]]; then
  HEADLESS=true
fi

if [[ "$OS" == "Darwin" ]]; then
  info "Detected macOS."
elif [[ "$OS" == "Linux" ]]; then
  info "Detected Linux (Headless: $HEADLESS)."
else
  warn "Unsupported Operating System: $OS. Proceeding anyway..."
fi

# Ask for installation profile
INSTALL_PROFILE="full"
if [[ "$HEADLESS" == "true" ]]; then
  info "Detected headless environment (remote server/SSH)."
  if ask_yes_no "Do you want to use the Minimal Server profile (highly recommended for remote servers)?"; then
    INSTALL_PROFILE="minimal"
  fi
else
  if ! ask_yes_no "Do you want to install the Full Desktop profile (choose No for Minimal Server)?"; then
    INSTALL_PROFILE="minimal"
  fi
fi

info "Selected Profile: ${INSTALL_PROFILE^^}"

# 2. Dependency Installer
if ask_yes_no "Do you want to check and install missing dependencies?"; then
  if [[ "$OS" == "Darwin" ]]; then
    # Install Homebrew if missing
    if ! command -v brew &> /dev/null; then
      info "Homebrew not found. Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # Install packages
    if [[ "$INSTALL_PROFILE" == "minimal" ]]; then
      info "Installing dependencies via Homebrew (neovim, starship, zoxide, fzf, ripgrep, fd, unzip)..."
      brew install neovim starship zoxide fzf ripgrep fd unzip
    else
      info "Installing dependencies via Homebrew (neovim, starship, zoxide, fzf, ripgrep, fd, zsh, node, unzip)..."
      brew install neovim starship zoxide fzf ripgrep fd zsh node unzip
      
      # Install Ghostty on macOS if not installed
      if ! command -v ghostty &> /dev/null && ! brew list --cask ghostty &> /dev/null; then
        info "Installing Ghostty via Homebrew Cask..."
        brew install --cask ghostty
      fi
    fi
  elif [[ "$OS" == "Linux" ]]; then
    # Try finding apt-get, pacman, or dnf
    if command -v apt-get &> /dev/null; then
      info "Installing dependencies via apt-get..."
      sudo apt-get update
      if [[ "$INSTALL_PROFILE" == "minimal" ]]; then
        sudo apt-get install -y neovim starship zoxide fzf ripgrep fd-find curl git build-essential unzip
      else
        sudo apt-get install -y neovim starship zoxide fzf ripgrep fd-find zsh curl git build-essential unzip python3 python3-pip python3-venv
      fi
    elif command -v pacman &> /dev/null; then
      info "Installing dependencies via pacman..."
      if [[ "$INSTALL_PROFILE" == "minimal" ]]; then
        sudo pacman -Syu --needed neovim starship zoxide fzf ripgrep fd curl git base-devel unzip
      else
        sudo pacman -Syu --needed neovim starship zoxide fzf ripgrep fd zsh curl git base-devel unzip python python-pip
      fi
    elif command -v dnf &> /dev/null; then
      info "Installing dependencies via dnf..."
      if [[ "$INSTALL_PROFILE" == "minimal" ]]; then
        sudo dnf install -y neovim starship zoxide fzf ripgrep fd-find curl git make gcc gcc-c++ unzip
      else
        sudo dnf install -y neovim starship zoxide fzf ripgrep fd-find zsh curl git make gcc gcc-c++ unzip python3-pip
      fi
    else
      warn "No supported package manager found. Please install the following tools manually:"
      warn "neovim, starship, zoxide, fzf, ripgrep, fd, curl, git, make, gcc, unzip"
    fi

    # Install/configure Node.js
    install_node_choice

    # Handle fd/fdfind naming difference on Debian/Ubuntu/Fedora
    if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
      info "Creating symlink for fd..."
      mkdir -p "$HOME/.local/bin"
      ln -sfn "$(which fdfind)" "$HOME/.local/bin/fd"
    fi
  fi
  success "Dependencies updated!"
else
  info "Skipping dependency installation."
fi

# 3. Neovim Config Symlinking
if ask_yes_no "Do you want to install/symlink the Neovim configuration?"; then
  NVIM_CONFIG_DIR="$HOME/.config/nvim"
  if [ -d "$NVIM_CONFIG_DIR" ] || [ -f "$NVIM_CONFIG_DIR" ] || [ -L "$NVIM_CONFIG_DIR" ]; then
    # If it is a symlink pointing to our repo already, do nothing
    if [ -L "$NVIM_CONFIG_DIR" ] && [ "$(readlink "$NVIM_CONFIG_DIR")" -ef "$DOTFILES_DIR/nvim" ]; then
      success "Neovim configuration is already correctly symlinked!"
    else
      warn "Existing Neovim directory found at ${NVIM_CONFIG_DIR}."
      if ask_yes_no "Back up current configuration and replace it?"; then
        BACKUP_PATH="${NVIM_CONFIG_DIR}${BACKUP_SUFFIX}"
        mv "$NVIM_CONFIG_DIR" "$BACKUP_PATH"
        info "Backed up existing config to ${BACKUP_PATH}"
        ln -sfn "$DOTFILES_DIR/nvim" "$NVIM_CONFIG_DIR"
        success "Symlinked Neovim configuration!"
      else
        info "Skipping Neovim symlink."
      fi
    fi
  else
    mkdir -p "$HOME/.config"
    ln -sfn "$DOTFILES_DIR/nvim" "$NVIM_CONFIG_DIR"
    success "Symlinked Neovim configuration!"
  fi

  # Handle minimal profile flag file
  if [ -d "$NVIM_CONFIG_DIR" ] || [ -L "$NVIM_CONFIG_DIR" ]; then
    if [[ "$INSTALL_PROFILE" == "minimal" ]]; then
      touch "$NVIM_CONFIG_DIR/.minimal"
      info "Created minimal profile marker in Neovim config directory."
    else
      rm -f "$NVIM_CONFIG_DIR/.minimal"
    fi
  fi
fi

# 4. Ghostty Config Symlinking
if [[ "$INSTALL_PROFILE" == "full" ]]; then
  if ask_yes_no "Do you want to install/symlink the Ghostty configuration?"; then
    GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
    if [ -d "$GHOSTTY_CONFIG_DIR" ] || [ -f "$GHOSTTY_CONFIG_DIR" ] || [ -L "$GHOSTTY_CONFIG_DIR" ]; then
      if [ -L "$GHOSTTY_CONFIG_DIR" ] && [ "$(readlink "$GHOSTTY_CONFIG_DIR")" -ef "$DOTFILES_DIR/ghostty" ]; then
        success "Ghostty configuration is already correctly symlinked!"
      else
        warn "Existing Ghostty directory found at ${GHOSTTY_CONFIG_DIR}."
        if ask_yes_no "Back up current configuration and replace it?"; then
          BACKUP_PATH="${GHOSTTY_CONFIG_DIR}${BACKUP_SUFFIX}"
          mv "$GHOSTTY_CONFIG_DIR" "$BACKUP_PATH"
          info "Backed up existing config to ${BACKUP_PATH}"
          ln -sfn "$DOTFILES_DIR/ghostty" "$GHOSTTY_CONFIG_DIR"
          success "Symlinked Ghostty configuration!"
        else
          info "Skipping Ghostty symlink."
        fi
      fi
    else
      mkdir -p "$HOME/.config"
      ln -sfn "$DOTFILES_DIR/ghostty" "$GHOSTTY_CONFIG_DIR"
      success "Symlinked Ghostty configuration!"
    fi
  fi
else
  info "Skipping Ghostty configuration (Minimal Server profile active)."
fi

# 5. Oh My Zsh & Plugin Clones
if [[ "$INSTALL_PROFILE" == "full" ]] && command -v zsh &> /dev/null; then
  if ask_yes_no "Do you want to set up Oh My Zsh & Zsh plugins?"; then
    # Oh My Zsh Check
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
      info "Oh My Zsh not found. Installing Oh My Zsh..."
      RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    # Custom Plugin Clones
    ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    info "Installing zsh-autosuggestions..."
    mkdir -p "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
    if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions/.git" ]; then
      git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
    else
      (cd "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" && git pull)
    fi

    info "Installing zsh-syntax-highlighting..."
    mkdir -p "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
    if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting/.git" ]; then
      git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
    else
      (cd "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" && git pull)
    fi

    # Safely modify ~/.zshrc plugins array using python3 to avoid duplicate plugins
    ZSHRC="$HOME/.zshrc"
    if [ -f "$ZSHRC" ]; then
      info "Adding custom plugins to ~/.zshrc..."
      python3 -c "
import re
path = '$ZSHRC'
try:
    content = open(path).read()
    # Find plugins=(...) block
    match = re.search(r'plugins=\(([^)]*)\)', content)
    if match:
        existing = match.group(1).split()
        target = ['git', 'zsh-autosuggestions', 'zsh-syntax-highlighting']
        for t in target:
            if t not in existing:
                existing.append(t)
        new_plugins = 'plugins=(' + ' '.join(existing) + ')'
        content = re.sub(r'plugins=\([^)]*\)', new_plugins, content)
        open(path, 'w').write(content)
except Exception as e:
    print('Failed to automatically edit .zshrc plugins list:', e)
"
    fi
    success "Oh My Zsh and plugins ready!"
  fi
else
  info "Skipping Oh My Zsh & plugins setup (not applicable for Minimal profile or Zsh missing)."
fi

# 6. Sourcing dotfiles custom zsh in ~/.zshrc
ZSH_INTEGRATED=false
if [[ "$INSTALL_PROFILE" == "full" ]] && command -v zsh &> /dev/null; then
  if ask_yes_no "Do you want to append/update the custom Zsh integrations in your ~/.zshrc?"; then
    ZSHRC="$HOME/.zshrc"
    touch "$ZSHRC"

    # Define block to write
    BLOCK_START="# >>> CUSTOM DOTFILES CONFIGURATION >>>"
    BLOCK_END="# <<< CUSTOM DOTFILES CONFIGURATION <<<"
    CUSTOM_SOURCE="if [ -f \"$DOTFILES_DIR/zsh/custom.zsh\" ]; then\n  source \"$DOTFILES_DIR/zsh/custom.zsh\"\nfi"

    # Check if custom configuration block already exists
    if grep -Fq "$BLOCK_START" "$ZSHRC"; then
      info "Updating existing dotfiles loading block in ~/.zshrc..."
      # Replace content between markers
      python3 -c "
path = '$ZSHRC'
start = '$BLOCK_START'
end = '$BLOCK_END'
replacement = '$CUSTOM_SOURCE'
content = open(path).read()
import re
pattern = re.escape(start) + r'.*?' + re.escape(end)
new_content = re.sub(pattern, start + '\n' + replacement.replace('\\n', '\n') + '\n' + end, content, flags=re.DOTALL)
open(path, 'w').write(new_content)
"
    else
      info "Appending dotfiles loading block to ~/.zshrc..."
      echo -e "\n$BLOCK_START" >> "$ZSHRC"
      echo -e "if [ -f \"$DOTFILES_DIR/zsh/custom.zsh\" ]; then" >> "$ZSHRC"
      echo -e "  source \"$DOTFILES_DIR/zsh/custom.zsh\"" >> "$ZSHRC"
      echo -e "fi" >> "$ZSHRC"
      echo -e "$BLOCK_END" >> "$ZSHRC"
    fi
    success "Zsh integrations linked!"
    ZSH_INTEGRATED=true
  fi
else
  info "Skipping ~/.zshrc integrations (not applicable for Minimal profile or Zsh missing)."
fi

echo -e "\n${GREEN}${BOLD}=========================================="
echo "          Installation Complete!          "
echo "=========================================="
echo -e "${NC}"
if [[ "$ZSH_INTEGRATED" == "true" ]]; then
  info "Please restart your shell or run: source ~/.zshrc"
else
  info "Installation complete! Enjoy your new Neovim configuration."
fi
