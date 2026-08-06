# Helper to back up conflicting configurations and run stow
stow_package() {
  local package="$1"
  local target_path="$2"

  # Check if stow command is available
  if ! command -v stow &> /dev/null; then
    error "stow command not found! Please install GNU Stow, or allow the script to install dependencies."
    return 1
  fi

  # Determine indicator file to check if already symlinked
  local indicator=""
  case "$package" in
    nvim) indicator="init.lua" ;;
    ghostty) indicator="config" ;;
    yazi) indicator="yazi.toml" ;;
    hunk) indicator="config.toml" ;;
    herdr) indicator="config.toml" ;;
  esac

  local indicator_path="${target_path}/${indicator}"

  if [ -d "$target_path" ] || [ -f "$target_path" ] || [ -L "$target_path" ]; then
    # Check if already correctly symlinked via indicator file
    if [ -L "$indicator_path" ] && [ "$indicator_path" -ef "$DOTFILES_DIR/$package/$indicator" ]; then
      success "$package configuration is already correctly symlinked!"
      return 0
    else
      warn "Existing $package directory/file found at $target_path."
      if ask_yes_no "Back up current configuration and replace it with dotfiles version?"; then
        local backup_path="${target_path}${BACKUP_SUFFIX}"
        mv "$target_path" "$backup_path"
        info "Backed up existing config to $backup_path"
      else
        info "Skipping $package configuration."
        return 1
      fi
    fi
  fi

  # Ensure the target directory exists
  mkdir -p "$target_path"

  # Run Stow to symlink the package contents to the target directory
  if stow -d "$DOTFILES_DIR" -t "$target_path" "$package"; then
    success "Symlinked $package configuration using Stow!"
    return 0
  else
    error "Failed to symlink $package using Stow."
    return 1
  fi
}

# 3. Neovim Config Symlinking
if ask_yes_no "Do you want to install/symlink the Neovim configuration?"; then
  stow_package "nvim" "$HOME/.config/nvim"
  
  # Handle minimal profile flag file
  NVIM_CONFIG_DIR="$HOME/.config/nvim"
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
    stow_package "ghostty" "$HOME/.config/ghostty"
  fi
else
  info "Skipping Ghostty configuration (Minimal Server profile active)."
fi

# 5. Yazi Config Symlinking
if [[ "$INSTALL_PROFILE" == "full" ]]; then
  if ask_yes_no "Do you want to install/symlink the Yazi configuration?"; then
    stow_package "yazi" "$HOME/.config/yazi"
  fi
else
  info "Skipping Yazi configuration (Minimal Server profile active)."
fi

# 5.5. Hunk Config Symlinking
if ask_yes_no "Do you want to install/symlink the Hunk configuration?"; then
  stow_package "hunk" "$HOME/.config/hunk"
fi

# 5.5.5. Herdr Config Symlinking
if ask_yes_no "Do you want to install/symlink the Herdr configuration?"; then
  stow_package "herdr" "$HOME/.config/herdr"
fi

