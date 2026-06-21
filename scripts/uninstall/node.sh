# Remove fd symlink if created
FD_SYMLINK="$HOME/.local/bin/fd"
if [ -L "$FD_SYMLINK" ]; then
  info "Removing fd symlink..."
  rm "$FD_SYMLINK"
  success "Removed fd symlink."
fi

# Remove standalone Node.js if installed
if [ -d "$HOME/.local/lib/nodejs" ]; then
  if ask_yes_no "Do you want to delete the standalone Node.js installation (~/.local/lib/nodejs)?"; then
    info "Removing standalone Node.js..."
    rm -rf "$HOME/.local/lib/nodejs"
    rm -f "$HOME/.local/bin/node"
    rm -f "$HOME/.local/bin/npm"
    rm -f "$HOME/.local/bin/npx"
    success "Removed standalone Node.js."
  fi
fi
