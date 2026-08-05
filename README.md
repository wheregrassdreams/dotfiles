# Personal Nix Configuration

Personal Nix configuration for the MacBook and NixOS WSL. The repository owns
declarative system and Home Manager configuration, plus the standalone Neovim
configuration under `resources/nvim`.

## Outputs

| Target | Output | Purpose |
| --- | --- | --- |
| MacBook | `darwinConfigurations.macbook` | Full nix-darwin system |
| WSL | `nixosConfigurations.wsl` | NixOS WSL system |
| MacBook home | `homeConfigurations.zanelu-macbook` | Standalone Home Manager evaluation |

Run all commands from the repository root.

```zsh
# Validate all flake outputs without switching the current machine.
nix flake check 'path:.' --no-write-lock-file --no-eval-cache

# Switch the current MacBook system.
darwin-rebuild switch --flake .#macbook

# Switch NixOS WSL.
sudo nixos-rebuild switch --flake .#wsl

# Switch only the MacBook Home Manager configuration.
home-manager switch --flake .#zanelu-macbook
```

For Homebrew formulae, casks, and taps, use the Home Manager command above.
`darwin-rebuild` only bootstraps Homebrew itself and applies macOS system
configuration. The generated Brewfile synchronizes declared packages without
updating, upgrading, or removing undeclared packages by default. Use
`brew-sync --update`, `brew-sync --upgrade`, `brew-sync --cleanup`, or
`brew-sync --zap` only when that behavior is intentional.

## First bootstrap

Install Determinate Nix on macOS, clone this repository, then apply the
MacBook output. NixOS WSL is built from the `wsl` output; its tarball builder
is available at `.#nixosConfigurations.wsl.config.system.build.tarballBuilder`.

This repository does not contain host disks, hardware configuration, private
keys, or service data. Keep a boot/recovery path and independent backups before
switching a new host.

## Architecture

The detailed module boundaries and performance rules are in
[ARCHITECTURE.md](ARCHITECTURE.md).

- `configurations/hosts/`: machine facts and machine-local preferences.
- `configurations/profiles/`: explicit combinations of capabilities, such as `personal-mac`,
  `minimal-terminal`, `work`, and `homelab`.
- `modules/options/`: pure `my.*` interfaces.
- `modules/home/` and `modules/system/`: Home Manager and Darwin/NixOS
  adapters. `services` owns local service lifecycle; `connectivity` owns
  network connectivity such as Tailscale.
- `resources/`: versioned configuration deliberately deployed outside Nix.
- `secrets/`: encrypted SOPS material and its usage notes.

## Services and data

`my.services` manages only local service lifecycle and client tools. On
the MacBook, Homebrew formula installation and user-level `brew services`
lifecycle run during Home Manager activation. A service can be `external`,
`local-manual`, or `local-daemon`; `external` means Docker or another system
owns the process lifecycle.

Database data is never stored or backed up by this repository. Before enabling
a local daemon, define and independently verify its export, backup, and restore
procedure.

## Neovim

Nix installs the `nvim` binary. The editor configuration remains in
`resources/nvim` and is linked manually:

```zsh
mkdir -p ~/.config
ln -sfn "$PWD/resources/nvim" ~/.config/nvim
```

## Secrets

Secrets use SOPS with age. Read [secrets/README.md](secrets/README.md) before
creating or editing encrypted files. The helper command is:

```zsh
./scripts/edit-secrets.sh secrets/common.yaml
```

## Windows configuration

Windows configuration is intentionally outside this repository. Its source and
bootstrap instructions live in the local repository
`/Users/zanelu/Workspace/code/projects/windows-config`.
