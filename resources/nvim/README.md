# Neovim config

This directory is the standalone Neovim configuration for this repository.
It is versioned here, but it is not managed by Home Manager anymore.

## Usage

Keep the `nvim` binary installed via Nix, then link this directory into
`~/.config/nvim` manually:

```zsh
mkdir -p ~/.config
ln -sfn "$(git rev-parse --show-toplevel)/resources/nvim" ~/.config/nvim
```

If you want to keep a backup of an existing config first:

```zsh
mv ~/.config/nvim ~/.config/nvim.bak-$(date +%Y%m%d%H%M%S)
ln -sfn "$(git rev-parse --show-toplevel)/resources/nvim" ~/.config/nvim
```
