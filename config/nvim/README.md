# Neovim config

This directory is the standalone Neovim configuration for this dotfiles repo.
It is versioned here, but it is not managed by Home Manager anymore.

## Usage

Keep the `nvim` binary installed via Nix, then link this directory into
`~/.config/nvim` manually:

```zsh
mkdir -p ~/.config
ln -sfn ~/Developer/dotfiles/config/nvim ~/.config/nvim
```

If you want to keep a backup of an existing config first:

```zsh
mv ~/.config/nvim ~/.config/nvim.bak
ln -sfn ~/Developer/dotfiles/config/nvim ~/.config/nvim
```
