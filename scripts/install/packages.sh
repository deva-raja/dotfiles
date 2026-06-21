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
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # Install packages
    if [[ "$INSTALL_PROFILE" == "minimal" ]]; then
      info "Installing dependencies via Homebrew (neovim, starship, zoxide, fzf, ripgrep, fd, unzip, stow)..."
      brew install neovim starship zoxide fzf ripgrep fd unzip stow
    else
      info "Installing dependencies via Homebrew (neovim, starship, zoxide, fzf, ripgrep, fd, zsh, node, unzip, stow)..."
      brew install neovim starship zoxide fzf ripgrep fd zsh node unzip stow
      
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
        sudo apt-get install -y neovim starship zoxide fzf ripgrep fd-find curl git build-essential unzip stow
      else
        sudo apt-get install -y neovim starship zoxide fzf ripgrep fd-find zsh curl git build-essential unzip python3 python3-pip python3-venv stow
        
        if [[ "$INSTALL_YAZI" == "true" ]]; then
          info "Installing Yazi dependencies via apt-get..."
          sudo apt-get install -y ffmpeg jq poppler-utils ripgrep fd-find zoxide fzf imagemagick p7zip-full
          if ! command -v yazi &> /dev/null; then
            info "Installing Yazi via snap..."
            if command -v snap &> /dev/null; then
              sudo snap install yazi --classic
            else
              warn "Snap not found. Please install Yazi manually from: https://github.com/sxyazi/yazi"
            fi
          fi
        fi
      fi
    elif command -v pacman &> /dev/null; then
      info "Installing dependencies via pacman..."
      if [[ "$INSTALL_PROFILE" == "minimal" ]]; then
        sudo pacman -Syu --needed neovim starship zoxide fzf ripgrep fd curl git base-devel unzip stow
      else
        sudo pacman -Syu --needed neovim starship zoxide fzf ripgrep fd zsh curl git base-devel unzip python python-pip stow
        
        if [[ "$INSTALL_YAZI" == "true" ]]; then
          info "Installing Yazi and dependencies via pacman..."
          sudo pacman -Syu --needed yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide resvg imagemagick
        fi
      fi
    elif command -v dnf &> /dev/null; then
      info "Installing dependencies via dnf..."
      if [[ "$INSTALL_PROFILE" == "minimal" ]]; then
        sudo dnf install -y neovim starship zoxide fzf ripgrep fd-find curl git make gcc gcc-c++ unzip stow
      else
        sudo dnf install -y neovim starship zoxide fzf ripgrep fd-find zsh curl git make gcc gcc-c++ unzip python3-pip stow
        
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
      warn "neovim, starship, zoxide, fzf, ripgrep, fd, curl, git, make, gcc, unzip, stow"
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
