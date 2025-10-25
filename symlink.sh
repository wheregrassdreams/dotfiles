DOTFILES="$HOME/.dotfiles"

symlink() {
  src=$1
  dest=$2
  backup="$dest.bak"

  # 检查目标是否为目录或文件且不是符号链接
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then

    n=1
    while [ -e "$backup" ]; do
      backup="$dest.bak.$n"
      n=$((n + 1))
    done

    # 将原始文件或目录重命名为备份文件
    mv "$dest" "$backup"
    echo "Warning: Backed up existing $dest to $backup"
  fi

  # 创建符号链接，强制覆盖旧的符号链接
  ln -sfn "$src" "$dest"
  echo "Created symlink: $dest -> $src"
}

# 使用函数创建符号链接
symlink "$DOTFILES/neovide"                  "$HOME/.config/neovide/"
symlink "$DOTFILES/ssh/config"               "$HOME/.ssh/config"
symlink "$DOTFILES/zsh/zshrc"                "$HOME/.zshrc"
symlink "$DOTFILES/btop"                     "$HOME/.config/btop"
symlink "$DOTFILES/fd"                       "$HOME/.config/fd"
symlink "$DOTFILES/fish"                     "$HOME/.config/fish"
symlink "$DOTFILES/kitty"                    "$HOME/.config/kitty"
# symlink "$DOTFILES/nvim"                     "$HOME/.config/nvim"
symlink "$DOTFILES/astronvim"                "$HOME/.config/nvim"
symlink "$DOTFILES/starship/starship.toml"   "$HOME/.config/starship.toml"
symlink "$DOTFILES/yazi"                     "$HOME/.config/yazi"
symlink "$DOTFILES/zellij"                   "$HOME/.config/zellij"
symlink "$DOTFILES/skhd"                     "$HOME/.config/skhd"
symlink "$DOTFILES/yabai"                    "$HOME/.config/yabai"
symlink "$DOTFILES/aerospace/aerospace.toml" "$HOME/.aerospace.toml"
symlink "$DOTFILES/ghostty"                  "$HOME/.config/ghostty"
symlink "$DOTFILES/lazygit"                  "$HOME/.config/lazygit"
symlink "$DOTFILES/gitconfig/.gitconfig"     "$HOME/.gitconfig"
symlink "$DOTFILES/tmux/tmux.conf"           "$HOME/.tmux.conf"
symlink "$DOTFILES/tmux"                     "$HOME/.config/tmux"


# sh $DOTFILES/iterm2/setup.sh
