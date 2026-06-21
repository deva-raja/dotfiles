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

  if [[ "$NON_INTERACTIVE" == "true" ]]; then
    # Standalone User-space (choice 1)
    install_node_linux
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

# Execute Node installation choice
install_node_choice
