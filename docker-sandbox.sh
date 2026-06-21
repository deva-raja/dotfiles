#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Docker Sandbox Builder & Runner
# ==============================================================================

# Exit on error
set -e

# Directory path of the script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
  echo "Error: Docker is not installed or not in your PATH."
  echo "Please install Docker Desktop (macOS/Windows) or Docker Engine (Linux)."
  exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
  echo "Error: Docker daemon is not running. Please start Docker first."
  exit 1
fi

IMAGE_NAME="dotfiles-sandbox"

echo "================================================================="
echo " Building Dotfiles Sandbox Docker Image: ${IMAGE_NAME}..."
echo "================================================================="
docker build -t "$IMAGE_NAME" "$DIR"

echo ""
echo "================================================================="
echo " Sandbox Environment Ready!"
echo "================================================================="
echo " You are entering an isolated, clean Ubuntu container."
echo " This container runs exactly the dotfiles installation script."
echo ""
echo " Tools available in this sandbox:"
echo "   - Shell: Zsh (with Oh My Zsh, custom plugins, and Starship prompt)"
echo "   - Editor: Neovim (v or nvim) with lazy.nvim configs"
echo "   - File Manager: Yazi (y or yazi) with custom integrations"
echo "   - Navigation: Zoxide (z <dir>) smart directory changer"
echo "   - Fuzzy Finder: fzf (Ctrl+R / Ctrl+T)"
echo ""
echo " Type 'v' or 'nvim' to start Neovim inside the sandbox."
echo " Type 'exit' to exit and destroy the container (isolated and safe)."
echo "================================================================="
echo ""

# Run the container interactively
docker run -it --rm "$IMAGE_NAME"
