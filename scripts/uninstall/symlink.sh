# Helper to unstow and restore backups
unstow_package() {
  local package="$1"
  local target_path="$2"

  # Determine indicator file to check if already symlinked
  local indicator=""
  case "$package" in
    nvim) indicator="init.lua" ;;
    ghostty) indicator="config" ;;
    yazi) indicator="yazi.toml" ;;
    hunk) indicator="config.toml" ;;
  esac

  local indicator_path="${target_path}/${indicator}"

  if [ -L "$indicator_path" ] && [ "$indicator_path" -ef "$DOTFILES_DIR/$package/$indicator" ]; then
    info "Removing $package configuration symlink using Stow..."
    if command -v stow &> /dev/null; then
      stow -D -d "$DOTFILES_DIR" -t "$target_path" "$package"
      success "Unstowed $package configuration."
    else
      rm -f "$target_path/$indicator"
      success "Removed $package symlink manually."
    fi

    # If the directory is now empty, remove it so we can restore the backup
    if [ -d "$target_path" ] && [ -z "$(ls -A "$target_path" 2>/dev/null)" ]; then
      rmdir "$target_path"
    fi
    restore_backup "$target_path"
  elif [ -d "$target_path" ] || [ -f "$target_path" ]; then
    if ask_yes_no "Found a non-symlink $package config folder at $target_path. Delete it?"; then
      rm -rf "$target_path"
      success "Deleted $package config folder."
      restore_backup "$target_path"
    fi
  fi
}

# 1. Neovim Config Removal & Backup Restore
rm -f "$HOME/.config/nvim/.minimal" 2>/dev/null || true
rm -f "$DOTFILES_DIR/nvim/.minimal" 2>/dev/null || true
unstow_package "nvim" "$HOME/.config/nvim"

# 2. Neovim Plugins, Cache, and State Clean up
if ask_yes_no "Delete Neovim local package cache and state directories (highly recommended to start fresh)?"; then
  info "Cleaning Neovim user data/cache directories..."
  rm -rf "$HOME/.local/share/nvim"
  rm -rf "$HOME/.local/state/nvim"
  rm -rf "$HOME/.cache/nvim"
  success "Cleaned Neovim data, state, and cache folders."
fi

# 3. Ghostty Config Removal & Backup Restore
unstow_package "ghostty" "$HOME/.config/ghostty"

# 3.5. Yazi Config Removal & Backup Restore
unstow_package "yazi" "$HOME/.config/yazi"

# 3.7. Hunk Config Removal & Backup Restore
unstow_package "hunk" "$HOME/.config/hunk"
