# Oh My Zsh & Custom Plugins Removal
if ask_yes_no "Do you want to delete Oh My Zsh and its custom plugins (~/.oh-my-zsh)?"; then
  if [ -d "$HOME/.oh-my-zsh" ]; then
    info "Deleting ~/.oh-my-zsh..."
    rm -rf "$HOME/.oh-my-zsh"
    success "Deleted Oh My Zsh directory."
  else
    info "Oh My Zsh directory not found."
  fi

  ZSHRC="$HOME/.zshrc"
  if [ -f "$ZSHRC" ]; then
    if command -v python3 &> /dev/null; then
      info "Removing custom plugins from ~/.zshrc plugins list..."
      python3 -c "
import re
path = '$ZSHRC'
try:
    content = open(path).read()
    match = re.search(r'plugins=\(([^)]*)\)', content)
    if match:
        existing = match.group(1).split()
        target = ['zsh-autosuggestions', 'zsh-syntax-highlighting']
        new_list = [x for x in existing if x not in target]
        new_plugins = 'plugins=(' + ' '.join(new_list) + ')'
        content = re.sub(r'plugins=\([^)]*\)', new_plugins, content)
        open(path, 'w').write(content)
        print('SUCCESS')
except Exception as e:
    print('ERROR:', e)
" | grep -q "SUCCESS" && success "Cleaned plugins array in ~/.zshrc." || warn "Failed to clean plugins array in ~/.zshrc."
    else
      warn "python3 not found. Skipping automatic plugins list cleanup."
    fi
  fi
fi

# Clean Zsh Custom Integrations in ~/.zshrc
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
  if ask_yes_no "Do you want to remove dotfiles custom configurations block from ~/.zshrc?"; then
    if command -v python3 &> /dev/null; then
      info "Removing dotfiles block from ~/.zshrc..."
      python3 -c "
import re
path = '$ZSHRC'
try:
    content = open(path).read()
    start = '# >>> CUSTOM DOTFILES CONFIGURATION >>>'
    end = '# <<< CUSTOM DOTFILES CONFIGURATION <<<'
    pattern = re.escape(start) + r'.*?' + re.escape(end)
    new_content = re.sub(pattern, '', content, flags=re.DOTALL)
    # Clean up excessive newlines
    new_content = re.sub(r'\n{3,}', '\n\n', new_content)
    open(path, 'w').write(new_content)
    print('SUCCESS')
except Exception as e:
    print('ERROR:', e)
" | grep -q "SUCCESS" && success "Cleaned ~/.zshrc." || error "Failed to automatically edit ~/.zshrc."
    else
      warn "python3 not found. Skipping automatic ~/.zshrc clean up."
    fi
  fi
fi
