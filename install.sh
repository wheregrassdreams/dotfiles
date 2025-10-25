#!/bin/bash

# install homebrew
# from https://brew.sh

if ! command -v curl; then
  if ! command -v brew 2>&1 >/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo >> ~/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else 
  echo "没有curl命令，请手动下载homebrew"
  exit 1
fi

# environment

brew install node
brew install oven-sh/bun/bun
brew install python
brew install go
brew install rustup


# install 

brew install tree
brew install curl
brew install wget
brew install git
brew install zip
brew install docker
brew install docker-compose


# cool cli tools
brew install imagemagick
brew install zoxide         # cd -> zoxide
brew install neovim
brew install eza            # ls -> eza
brew install btop           # top -> btop 
brew install tldr           # man -> tldr
brew install yazi
brew install bat            # cat -> bat
brew install fastfetch      # neofetch -> fastfetch
brew install fd             # find -> fd 
brew install ripgrep        # grep -> ripgrep
brew install gdu            # du -> gdu
brew install lazydocker
brew install fzf            # fuzzy search
brew install starship
brew install tokei          # count code lines 

brew install lazygit
brew install gh             # github cli
brew install git-delta          # git diff -> delta

brew tap xenodium/macosrec
brew install macosrec       # Take screenshots/videos of macOS windows from the command line 

# blog
brew install hugo


# oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# zsh extensions
# TODO: zshrc中添加source
brew install zsh-system-clipboard
brew install zsh-vi-mode
brew insatll zsh-autosuggestions
brew install zsh-fast-syntax-highlighting
# git clone https://github.com/kutsan/zsh-system-clipboard ${ZSH_CUSTOM:-~/.zsh}/plugins/zsh-system-clipboard
# git clone https://github.com/jeffreytse/zsh-vi-mode $ZSH_CUSTOM/plugins/zsh-vi-mode
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestion

# 
rustup-init

# im-select
curl -Ls https://raw.githubusercontent.com/daipeihust/im-select/master/install_mac.sh | sh

# os building 
brew install qemu
brew install x86_64-elf-gcc
brew install x86_64-elf-gdb
brew install cmake
brew install nasm

# proxy 
brew install mitmproxy

# other
brew install ffmpeg


# Mac App
# brew install --cask visual-studio-code
# brew install --cask kitty
# brew install --cask iterm2
# brew install --cask ghostty

# brew install --cask obsidian
# brew install --cask zerotier-one
# brew install --cask arc
# brew install --cask clash-verge-rev
# brew install syncthing
# brew install --cask picgo
# brew install --cask raycast

# brew install --cask orbstack

# brew install --cask hbuilderx

# brew install --cask neteasemusic
# brew install --cask obs
# brew install --cask figma
# brew install gifski
# brew install --cask wechat
# brew install --cask localsend
# brew install --cask chatgpt
# brew install --cask betterdisplay
# brew install --cask hiddenbar
# brew install --cask ticktick
# brew install --cask affinity-designer
# brew install --cask tor-browser
# brew install --cask moonlight

# brew install --cask lookaway
# brew install --cask nikitabobko/tap/aerospace
# brew install --cask cheatsheet
# brew install --cask bartender

# brew install mas
# mas install 1429033973 # runcat
# mas install 1221250572 # xnip 
