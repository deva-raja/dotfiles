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

# Resolve and validate the target path to mount
MOUNT_PATH=""
if [ -n "$1" ]; then
  if [ -d "$1" ]; then
    MOUNT_PATH="$(cd "$1" && pwd)"
  else
    echo "Error: Directory '$1' does not exist."
    exit 1
  fi
else
  MOUNT_PATH="$(pwd)"
fi

echo ""
echo "================================================================="
echo " Sandbox Environment Ready!"
echo "================================================================="
echo " You are entering an isolated, clean Ubuntu container."
echo " This container runs exactly the dotfiles installation script."
echo ""

if [ "$MOUNT_PATH" != "$DIR" ]; then
  echo " Mounting host directory: ${MOUNT_PATH} -> /workspace"
  echo " Working directory inside container: /workspace"
else
  echo " Running in isolated mode (no host project mounted)."
  echo " To edit host files, pass the path parameter. E.g.:"
  echo "   make docker-sandbox path=/path/to/your/project"
fi

echo ""
echo " Tools available in this sandbox:"
echo "   - Shell: Zsh (with Oh My Zsh, custom plugins, and Starship prompt)"
echo "   - Editor: Neovim (v or nvim) with lazy.nvim configs"
echo "   - File Manager: Yazi (yf or yazi) with custom integrations"
echo ""
echo " Getting Started:"
echo "   - Type 'v' or 'nvim' to start editing your files."
echo "   - Type 'yf' or 'yazi' to open the terminal file manager."
echo "   - Type 'exit' to exit and destroy the container (isolated and safe)."
echo "================================================================="
echo ""

# Run the container interactively
if [ "$MOUNT_PATH" != "$DIR" ]; then
  docker run -it --rm -v "${MOUNT_PATH}":/workspace -w /workspace "$IMAGE_NAME"
else
  docker run -it --rm "$IMAGE_NAME"
fi
