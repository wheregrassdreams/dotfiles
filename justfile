# Repository-local command entry points. Run `just --list` to discover them.

default:
  @just --list

# Evaluate all declared flake checks without changing the active machine.
check:
  nix flake check 'path:.' --no-write-lock-file --no-eval-cache

# Build, but do not activate, the MacBook system configuration.
build-darwin:
  darwin-rebuild build --flake .#macbook

# Build, but do not activate, the standalone MacBook Home Manager configuration.
build-home:
  nix run --inputs-from . home-manager -- build --flake .#zanelu-macbook

# Apply the MacBook system configuration. This is intentionally explicit because it uses sudo.
switch-darwin:
  sudo darwin-rebuild switch --flake .#macbook

# Apply only the MacBook Home Manager configuration, including the Homebrew package sync.
switch-home:
  nix run --inputs-from . home-manager -- switch --flake .#zanelu-macbook

# Apply the NixOS WSL configuration. Run this from WSL.
switch-wsl:
  sudo nixos-rebuild switch --flake .#wsl

# Restore the deliberately external Neovim configuration reference.
link-nvim:
  mkdir -p "$HOME/.config"
  ln -sfn "{{justfile_directory()}}/resources/nvim" "$HOME/.config/nvim"

# Edit an encrypted SOPS file, for example: `just edit-secret secrets/common.yaml`.
edit-secret secret_file:
  ./scripts/edit-secrets.sh "{{secret_file}}"
