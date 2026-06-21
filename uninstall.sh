#!/usr/bin/env bash

# ==============================================================================
# Dotfiles Uninstaller & Cleanup Script (Modular Coordinator)
# ==============================================================================

# Exit on error (except where handled)
set -e

# Directory paths
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared utility script
source "${DOTFILES_DIR}/scripts/utils.sh"

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

# 1. Unstow symlinks and restore backups
source "${DOTFILES_DIR}/scripts/uninstall/symlink.sh"

# 2. Uninstall Oh My Zsh and custom configs
source "${DOTFILES_DIR}/scripts/uninstall/zsh.sh"

# 3. Clean up fd symlink and standalone Node.js
source "${DOTFILES_DIR}/scripts/uninstall/node.sh"

# 4. Package Uninstallation
source "${DOTFILES_DIR}/scripts/uninstall/packages.sh"

# 5. Self-destruction of the dotfiles repository
echo -e "\n${RED}${BOLD}=========================================="
echo "          Self-Deletes Dotfiles           "
echo "=========================================="
echo -e "${NC}"
if [[ "$NON_INTERACTIVE" == "true" ]]; then
  info "Non-interactive mode active. Skipping self-deletion of dotfiles directory."
else
  if ask_yes_no "Do you want to delete this dotfiles repository directory ($DOTFILES_DIR)?"; then
    info "Self-deleting dotfiles directory..."
    rm -rf "$DOTFILES_DIR"
    success "Dotfiles repository deleted! Uninstallation complete."
  else
    success "Uninstallation complete. Dotfiles repository kept at ${DOTFILES_DIR}."
  fi
fi
