DOTFILES="$HOME/.dotfiles"

_ln() {
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
# _ln "$DOTFILES/neovide"                  "$HOME/.config/neovide/"
_ln "$DOTFILES/ssh/config"               "$HOME/.ssh/config"
_ln "$DOTFILES/zsh/zshrc"                "$HOME/.zshrc"
_ln "$DOTFILES/btop"                     "$HOME/.config/btop"
_ln "$DOTFILES/fd"                       "$HOME/.config/fd"
_ln "$DOTFILES/fish"                     "$HOME/.config/fish"
_ln "$DOTFILES/kitty"                    "$HOME/.config/kitty"
# _ln "$DOTFILES/nvim"                     "$HOME/.config/nvim"
_ln "$DOTFILES/astronvim"                "$HOME/.config/nvim"
_ln "$DOTFILES/lazyvim"                  "$HOME/.config/lazyvim"
_ln "$DOTFILES/starship/starship.toml"   "$HOME/.config/starship.toml"
_ln "$DOTFILES/yazi"                     "$HOME/.config/yazi"
_ln "$DOTFILES/zellij"                   "$HOME/.config/zellij"
_ln "$DOTFILES/skhd"                     "$HOME/.config/skhd"
_ln "$DOTFILES/yabai"                    "$HOME/.config/yabai"
_ln "$DOTFILES/aerospace/aerospace.toml" "$HOME/.aerospace.toml"
_ln "$DOTFILES/ghostty"                  "$HOME/.config/ghostty"
_ln "$DOTFILES/lazygit"                  "$HOME/.config/lazygit"
_ln "$DOTFILES/gitconfig/gitconfig"      "$HOME/.gitconfig"
_ln "$DOTFILES/tmux/tmux.conf"           "$HOME/.tmux.conf"
_ln "$DOTFILES/tmux"                     "$HOME/.config/tmux"


# sh $DOTFILES/iterm2/setup.sh
