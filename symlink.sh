dotfiles="$HOME/.dotfiles"

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
_ln "$dotfiles/ssh/config"               "$HOME/.ssh/config"
_ln "$dotfiles/zsh/zshrc"                "$HOME/.zshrc"
_ln "$dotfiles/btop"                     "$HOME/.config/btop"
_ln "$dotfiles/fd"                       "$HOME/.config/fd"
_ln "$dotfiles/fish"                     "$HOME/.config/fish"
_ln "$dotfiles/kitty"                    "$HOME/.config/kitty"
_ln "$dotfiles/eza"                      "$HOME/.config/eza"
# _ln "$DOTFILES/nvim"                     "$HOME/.config/nvim"
_ln "$dotfiles/astronvim"                "$HOME/.config/nvim"
_ln "$dotfiles/lazyvim"                  "$HOME/.config/lazyvim"
_ln "$dotfiles/starship/starship.toml"   "$HOME/.config/starship.toml"
_ln "$dotfiles/yazi"                     "$HOME/.config/yazi"
_ln "$dotfiles/zellij"                   "$HOME/.config/zellij"
_ln "$dotfiles/skhd"                     "$HOME/.config/skhd"
_ln "$dotfiles/yabai"                    "$HOME/.config/yabai"
_ln "$dotfiles/aerospace/aerospace.toml" "$HOME/.aerospace.toml"
_ln "$dotfiles/ghostty"                  "$HOME/.config/ghostty"
_ln "$dotfiles/lazygit"                  "$HOME/.config/lazygit"
_ln "$dotfiles/gitconfig/gitconfig"      "$HOME/.gitconfig"
_ln "$dotfiles/tmux/tmux.conf"           "$HOME/.tmux.conf"
_ln "$dotfiles/tmux"                     "$HOME/.config/tmux"
_ln "$dotfiles/aichat"                   "$HOME/.config/aichat"


# sh $DOTFILES/iterm2/setup.sh
