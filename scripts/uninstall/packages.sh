# Package Uninstallation
if ask_yes_no "Do you want to uninstall system packages installed by the dotfiles installer (neovim, starship, zoxide, fzf, ripgrep, fd-find, zsh, yazi, ghostty, stow)?"; then
  if [[ "$OS" == "Darwin" ]]; then
    info "Uninstalling dependencies via Homebrew..."
    brew uninstall --force neovim starship zoxide fzf ripgrep fd zsh unzip yazi ffmpeg sevenzip jq poppler imagemagick stow || true
    info "Uninstalling Ghostty via Homebrew Cask..."
    brew uninstall --cask --force ghostty || true
  elif [[ "$OS" == "Linux" ]]; then
    # Clean up manually installed Neovim files under ~/.local if present
    if [[ -f "$HOME/.local/bin/nvim" ]]; then
      info "Removing manually installed Neovim binary and files..."
      rm -f "$HOME/.local/bin/nvim"
      rm -rf "$HOME/.local/lib/nvim"
      rm -f "$HOME/.local/share/man/man1/nvim.1"
    fi

    # Clean up manually installed tree-sitter binary under ~/.local/bin if present
    if [[ -f "$HOME/.local/bin/tree-sitter" ]]; then
      info "Removing manually installed tree-sitter binary..."
      rm -f "$HOME/.local/bin/tree-sitter"
    fi

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
