# Oh My Zsh & Plugin Clones
if [[ "$INSTALL_PROFILE" == "full" ]] && command -v zsh &> /dev/null; then
  if ask_yes_no "Do you want to set up Oh My Zsh & Zsh plugins?"; then
    # Oh My Zsh Check
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
      info "Oh My Zsh not found. Installing Oh My Zsh..."
      RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi

    # Custom Plugin Clones
    ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    info "Installing zsh-autosuggestions..."
    mkdir -p "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
    if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions/.git" ]; then
      git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
    else
      (cd "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" && git pull)
    fi

    info "Installing zsh-syntax-highlighting..."
    mkdir -p "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
    if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting/.git" ]; then
      git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
    else
      (cd "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" && git pull)
    fi

    # Safely modify ~/.zshrc plugins array using python3 to avoid duplicate plugins
    ZSHRC="$HOME/.zshrc"
    if [ -f "$ZSHRC" ]; then
      if command -v python3 &> /dev/null; then
        info "Adding custom plugins to ~/.zshrc..."
        python3 -c "
import re
path = '$ZSHRC'
try:
    content = open(path).read()
    # Find plugins=(...) block
    match = re.search(r'plugins=\(([^)]*)\)', content)
    if match:
        existing = match.group(1).split()
        target = ['git', 'zsh-autosuggestions', 'zsh-syntax-highlighting']
        for t in target:
            if t not in existing:
                existing.append(t)
        new_plugins = 'plugins=(' + ' '.join(existing) + ')'
        content = re.sub(r'plugins=\([^)]*\)', new_plugins, content)
        open(path, 'w').write(content)
except Exception as e:
    print('Failed to automatically edit .zshrc plugins list:', e)
"
      else
        warn "python3 not found. Skipping automatic plugins array modification."
      fi
    fi
    success "Oh My Zsh and plugins ready!"
  fi
else
  info "Skipping Oh My Zsh & plugins setup (not applicable for Minimal profile or Zsh missing)."
fi

# Sourcing dotfiles custom zsh in ~/.zshrc
ZSH_INTEGRATED=false
if [[ "$INSTALL_PROFILE" == "full" ]] && command -v zsh &> /dev/null; then
  if ask_yes_no "Do you want to append/update the custom Zsh integrations in your ~/.zshrc?"; then
    ZSHRC="$HOME/.zshrc"
    touch "$ZSHRC"

    # Define block to write
    BLOCK_START="# >>> CUSTOM DOTFILES CONFIGURATION >>>"
    BLOCK_END="# <<< CUSTOM DOTFILES CONFIGURATION <<<"
    CUSTOM_SOURCE="if [ -f \"$DOTFILES_DIR/zsh/custom.zsh\" ]; then\n  source \"$DOTFILES_DIR/zsh/custom.zsh\"\nfi"

    # Check if custom configuration block already exists
    if grep -Fq "$BLOCK_START" "$ZSHRC"; then
      info "Updating existing dotfiles loading block in ~/.zshrc..."
      # Replace content between markers
      if command -v python3 &> /dev/null; then
        python3 -c "
path = '$ZSHRC'
start = '$BLOCK_START'
end = '$BLOCK_END'
replacement = '$CUSTOM_SOURCE'
content = open(path).read()
import re
pattern = re.escape(start) + r'.*?' + re.escape(end)
new_content = re.sub(pattern, start + '\n' + replacement.replace('\\n', '\n') + '\n' + end, content, flags=re.DOTALL)
open(path, 'w').write(new_content)
"
      else
        warn "python3 not found. Could not update existing block in ~/.zshrc."
      fi
    else
      info "Appending dotfiles loading block to ~/.zshrc..."
      echo -e "\n$BLOCK_START" >> "$ZSHRC"
      echo -e "if [ -f \"$DOTFILES_DIR/zsh/custom.zsh\" ]; then" >> "$ZSHRC"
      echo -e "  source \"$DOTFILES_DIR/zsh/custom.zsh\"" >> "$ZSHRC"
      echo -e "fi" >> "$ZSHRC"
      echo -e "$BLOCK_END" >> "$ZSHRC"
    fi
    success "Zsh integrations linked!"
    ZSH_INTEGRATED=true
  fi
else
  info "Skipping ~/.zshrc integrations (not applicable for Minimal profile or Zsh missing)."
fi
