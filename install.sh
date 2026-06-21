# !/usr/bin/env bash

# ==============================================================================
# Dotfiles Installer & Bootstrapper (Modular Coordinator)
# ==============================================================================

# Exit on error (except where handled)
set -e

# Directory paths
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SUFFIX=".bak.$(date +%F-%H%M%S)"

# Source shared utility script
source "${DOTFILES_DIR}/scripts/utils.sh"

# Parse options
NON_INTERACTIVE=false
PROFILE_OVERRIDE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes|--non-interactive)
      NON_INTERACTIVE=true
      shift
      ;;
    -p|--profile)
      PROFILE_OVERRIDE="$2"
      shift 2
      ;;
    --full)
      PROFILE_OVERRIDE="full"
      shift
      ;;
    --minimal)
      PROFILE_OVERRIDE="minimal"
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  -y, --yes, --non-interactive  Run in non-interactive mode (auto-accept all prompts)"
      echo "  -p, --profile <profile>       Choose profile: 'full' or 'minimal'"
      echo "  --full                        Shortcut for --profile full"
      echo "  --minimal                     Shortcut for --profile minimal"
      echo "  -h, --help                    Show this help message"
      exit 0
      ;;
    *)
      warn "Unknown option: $1"
      shift
      ;;
  esac
done

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
if [[ -n "$PROFILE_OVERRIDE" ]]; then
  if [[ "$PROFILE_OVERRIDE" == "minimal" || "$PROFILE_OVERRIDE" == "full" ]]; then
    INSTALL_PROFILE="$PROFILE_OVERRIDE"
  else
    warn "Invalid profile '$PROFILE_OVERRIDE'. Defaulting based on environment."
  fi
fi

if [[ -z "$PROFILE_OVERRIDE" ]]; then
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
fi

info "Selected Profile: $(echo "$INSTALL_PROFILE" | tr '[:lower:]' '[:upper:]')"

# 2. Dependency Installer
source "${DOTFILES_DIR}/scripts/install/packages.sh"

# 3. Symlink configuration via Stow
source "${DOTFILES_DIR}/scripts/install/symlink.sh"

# 4. Zsh plugins & configuration
source "${DOTFILES_DIR}/scripts/install/zsh.sh"

echo -e "\n${GREEN}${BOLD}=========================================="
echo "          Installation Complete!          "
echo "=========================================="
echo -e "${NC}"
if [[ "$ZSH_INTEGRATED" == "true" ]]; then
  info "Please restart your shell or run: source ~/.zshrc"
else
  info "Installation complete! Enjoy your new Neovim configuration."
fi
