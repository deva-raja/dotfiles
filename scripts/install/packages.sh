# Dependency Installer
if ask_yes_no "Do you want to check and install missing dependencies?"; then
  INSTALL_YAZI=false
  if [[ "$INSTALL_PROFILE" == "full" ]]; then
    if ask_yes_no "Do you want to install Yazi (terminal file manager) and its optional preview dependencies?"; then
      INSTALL_YAZI=true
    fi
  fi

  if [[ "$OS" == "Darwin" ]]; then
    # Install Homebrew if missing
    if ! command -v brew &> /dev/null; then
      info "Homebrew not found. Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL --retry 3 --retry-delay 2 https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # Install packages
    if [[ "$INSTALL_PROFILE" == "minimal" ]]; then
      info "Installing dependencies via Homebrew (neovim, starship, zoxide, fzf, ripgrep, fd, tmux, unzip, stow, tree-sitter)..."
      brew install neovim starship zoxide fzf ripgrep fd tmux unzip stow tree-sitter
    else
      info "Installing dependencies via Homebrew (neovim, starship, zoxide, fzf, ripgrep, fd, tmux, zsh, node, unzip, stow, tree-sitter)..."
      brew install neovim starship zoxide fzf ripgrep fd tmux zsh node unzip stow tree-sitter
      
      # Install Ghostty on macOS if not installed
      if ! command -v ghostty &> /dev/null && ! brew list --cask ghostty &> /dev/null; then
        info "Installing Ghostty via Homebrew Cask..."
        brew install --cask ghostty
      fi

      if [[ "$INSTALL_YAZI" == "true" ]]; then
        info "Installing Yazi and optional dependencies via Homebrew..."
        brew install yazi ffmpeg sevenzip jq poppler imagemagick
      fi
    fi
  elif [[ "$OS" == "Linux" ]]; then
    # Try finding apt-get, pacman, or dnf
    if command -v apt-get &> /dev/null; then
      info "Installing dependencies via apt-get..."
      sudo apt-get update
      if [[ "$INSTALL_PROFILE" == "minimal" ]]; then
        sudo apt-get install -y zoxide fzf ripgrep fd-find tmux curl git build-essential unzip stow
      else
        sudo apt-get install -y zoxide fzf ripgrep fd-find tmux zsh curl git build-essential unzip python3 python3-pip python3-venv stow
      fi

      # Install Starship via official install script since it is not in default APT repositories
      if ! command -v starship &> /dev/null; then
        info "Installing Starship..."
        mkdir -p "$HOME/.local/bin"
        curl -sS --retry 3 --retry-delay 2 https://starship.rs/install.sh | sh -s -- --bin-dir "$HOME/.local/bin" -y
      fi

      # Install/Update Neovim to 0.11+ if missing or older
      INSTALL_NVIM=false
      if ! command -v nvim &> /dev/null; then
        INSTALL_NVIM=true
      else
        nvim_ver=$(nvim --version | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        major=$(echo "$nvim_ver" | cut -d. -f1)
        minor=$(echo "$nvim_ver" | cut -d. -f2)
        if [[ -z "$major" || -z "$minor" ]] || (( major == 0 && minor < 11 )); then
          INSTALL_NVIM=true
        fi
      fi

      if [[ "$INSTALL_NVIM" == "true" ]]; then
        info "Installing Neovim (latest stable release) precompiled binary..."
        mkdir -p "$HOME/.local/bin"
        ARCH="$(uname -m)"
        NVIM_ARCH=""
        if [ "$ARCH" = "x86_64" ]; then
          NVIM_ARCH="x86_64"
        elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
          NVIM_ARCH="arm64"
        fi

        if [ -n "$NVIM_ARCH" ]; then
          NVIM_TAR="nvim-linux-${NVIM_ARCH}.tar.gz"
          NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/${NVIM_TAR}"
          info "Downloading Neovim from ${NVIM_URL}..."
          if curl -LO --retry 3 --retry-delay 2 "$NVIM_URL"; then
            tar -C "$HOME/.local" -xzf "$NVIM_TAR" --strip-components=1
            rm -rf "$NVIM_TAR"
            success "Neovim installed successfully in ~/.local!"
          else
            warn "Failed to download Neovim. Falling back to default package..."
            sudo apt-get install -y neovim
          fi
        else
          warn "Unsupported architecture for Neovim precompiled binary: $ARCH. Falling back to package manager..."
          sudo apt-get install -y neovim
        fi
      fi
        
        if [[ "$INSTALL_YAZI" == "true" ]]; then
          info "Installing Yazi dependencies via apt-get..."
          sudo apt-get install -y ffmpeg jq poppler-utils ripgrep fd-find zoxide fzf imagemagick p7zip-full
          if ! command -v yazi &> /dev/null; then
            if command -v snap &> /dev/null; then
              info "Installing Yazi via snap..."
              sudo snap install yazi --classic
            else
              info "Snap not found. Installing Yazi precompiled binary from GitHub..."
              mkdir -p "$HOME/.local/bin"
              ARCH="$(uname -m)"
              YAZI_ARCH=""
              if [ "$ARCH" = "x86_64" ]; then
                YAZI_ARCH="x86_64-unknown-linux-musl"
              elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
                YAZI_ARCH="aarch64-unknown-linux-musl"
              fi
              
              if [ -n "$YAZI_ARCH" ]; then
                TARBALL="yazi-${YAZI_ARCH}.zip"
                DOWNLOAD_URL="https://github.com/sxyazi/yazi/releases/latest/download/${TARBALL}"
                info "Downloading Yazi from ${DOWNLOAD_URL}..."
                if curl -LO --retry 3 --retry-delay 2 "$DOWNLOAD_URL"; then
                  unzip -q "$TARBALL"
                  mv "yazi-${YAZI_ARCH}/yazi" "yazi-${YAZI_ARCH}/ya" "$HOME/.local/bin/"
                  rm -rf "$TARBALL" "yazi-${YAZI_ARCH}"
                  success "Yazi installed successfully in ~/.local/bin!"
                else
                  warn "Failed to download Yazi binary. Please install manually from: https://github.com/sxyazi/yazi"
                fi
              else
                warn "Unsupported architecture for Yazi precompiled binary: $ARCH. Please install manually."
              fi
            fi
          fi
        fi
    elif command -v pacman &> /dev/null; then
      info "Installing dependencies via pacman..."
      if [[ "$INSTALL_PROFILE" == "minimal" ]]; then
        sudo pacman -Syu --needed neovim starship zoxide fzf ripgrep fd tmux curl git base-devel unzip stow
      else
        sudo pacman -Syu --needed neovim starship zoxide fzf ripgrep fd tmux zsh curl git base-devel unzip python python-pip stow
        
        if [[ "$INSTALL_YAZI" == "true" ]]; then
          info "Installing Yazi and dependencies via pacman..."
          sudo pacman -Syu --needed yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick
        fi
      fi
    elif command -v dnf &> /dev/null; then
      info "Installing dependencies via dnf..."
      if [[ "$INSTALL_PROFILE" == "minimal" ]]; then
        sudo dnf install -y neovim starship zoxide fzf ripgrep fd-find tmux curl git make gcc gcc-c++ unzip stow
      else
        sudo dnf install -y neovim starship zoxide fzf ripgrep fd-find tmux zsh curl git make gcc gcc-c++ unzip python3-pip stow
        
        if [[ "$INSTALL_YAZI" == "true" ]]; then
          info "Installing Yazi and dependencies via dnf..."
          if ! command -v dnf-plugins-core &> /dev/null; then
            sudo dnf install -y dnf-plugins-core
          fi
          sudo dnf copr enable -y lihaohong/yazi
          sudo dnf install -y yazi ffmpeg 7zip jq poppler imagemagick
        fi
      fi
    else
      warn "No supported package manager found. Please install the following tools manually:"
      warn "neovim, starship, zoxide, fzf, ripgrep, fd, tmux, curl, git, make, gcc, unzip, stow"
    fi

    # Install/Update tree-sitter-cli to 0.22+ if missing or older (required by nvim-treesitter and kulala)
    INSTALL_TS=false
    if ! command -v tree-sitter &> /dev/null; then
      INSTALL_TS=true
    else
      ts_ver=$(tree-sitter --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
      major=$(echo "$ts_ver" | cut -d. -f1)
      minor=$(echo "$ts_ver" | cut -d. -f2)
      if [[ -z "$major" || -z "$minor" ]] || (( major == 0 && minor < 22 )); then
        INSTALL_TS=true
      fi
    fi

    if [[ "$INSTALL_TS" == "true" ]]; then
      info "Installing tree-sitter-cli (latest stable release) precompiled binary..."
      mkdir -p "$HOME/.local/bin"
      ARCH="$(uname -m)"
      TS_ARCH=""
      if [ "$ARCH" = "x86_64" ]; then
        TS_ARCH="x64"
      elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
        TS_ARCH="arm64"
      fi

      if [ -n "$TS_ARCH" ]; then
        TS_ZIP="tree-sitter-cli-linux-${TS_ARCH}.zip"
        TS_URL="https://github.com/tree-sitter/tree-sitter/releases/latest/download/${TS_ZIP}"
        info "Downloading tree-sitter-cli from ${TS_URL}..."
        if curl -LO --retry 3 --retry-delay 2 "$TS_URL"; then
          unzip -o "$TS_ZIP" -d "$HOME/.local/bin"
          chmod +x "$HOME/.local/bin/tree-sitter"
          rm -f "$TS_ZIP"
          success "tree-sitter-cli installed successfully in ~/.local/bin!"
        else
          warn "Failed to download tree-sitter-cli from GitHub."
        fi
      else
        warn "Unsupported architecture for tree-sitter-cli: $ARCH."
      fi
    fi

    # Install/configure Node.js
    source "${DOTFILES_DIR}/scripts/install/node.sh"

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
