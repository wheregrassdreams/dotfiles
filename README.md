# Personal Nix Configuration

Declarative macOS and NixOS WSL configuration, with Home Manager modules and
the standalone Neovim configuration in `resources/nvim`.

## Targets

| Target | Flake output |
| --- | --- |
| MacBook | `darwinConfigurations.macbook` |
| NixOS WSL | `nixosConfigurations.wsl` |
| MacBook Home Manager | `homeConfigurations.zanelu-macbook` |

## Everyday use

Run commands from the repository root. `just` selects the current MacBook or
WSL target where appropriate.

```zsh
just check
just fmt
just build
just switch
```

For an explicit target:

```zsh
darwin-rebuild switch --flake .#macbook
sudo nixos-rebuild switch --flake .#wsl
home-manager switch --flake .#zanelu-macbook
```

Trust direnv once after cloning:

```zsh
direnv allow
```

Run `just --list` for the full command list. `just switch-home` applies only
the MacBook Home Manager configuration, including declared Homebrew packages.
Use `brew-sync --cleanup` or `brew-sync --zap` only when removal is intended.

## First bootstrap

### macOS

Install Determinate Nix, clone this repository, enter it, trust direnv, then
apply the MacBook target:

```zsh
darwin-rebuild switch --flake .#macbook
home-manager switch --flake .#zanelu-macbook
```

### NixOS WSL

1. In Windows PowerShell, install NixOS to E: (change the location if needed):

   ```powershell
   $installer = Join-Path ([System.IO.Path]::GetTempPath()) 'install-nixos-wsl.ps1'; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/wheregrassdreams/dotfiles/bootstrap-v1/scripts/install-nixos-wsl.ps1' -OutFile $installer; & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer -InstallLocation 'E:\WSL\NixOS'; $status = $LASTEXITCODE; Remove-Item -LiteralPath $installer -Force; exit $status
   ```

2. Open the distribution:

   ```powershell
   wsl -d NixOS
   ```

3. In NixOS, run the versioned bootstrap:

   ```bash
   tmp="$(mktemp)"; curl --proto '=https' --tlsv1.2 -fsSL "https://raw.githubusercontent.com/wheregrassdreams/dotfiles/bootstrap-v1/scripts/bootstrap-nixos-wsl.sh" -o "$tmp" && bash "$tmp"; status=$?; rm -f "$tmp"; exit "$status"
   ```

   It temporarily obtains Git through Nix, builds, tests, and switches `.#wsl`,
   then installs the same checkout at `~/nix-config`. The initial clone uses
   HTTPS; after switch, the script can configure GitHub SSH at
   `~/.ssh/id_ed25519` and change `origin` to SSH.

4. Accept the shutdown prompt, or run `wsl --shutdown` in Windows PowerShell.
   Reopen NixOS and verify:

   ```zsh
   id
   git --version
   git config user.name
   cmd.exe /c ver
   ```

Daily WSL use is from the permanent checkout:

```zsh
cd ~/nix-config
just switch
```

Unlock the SSH key once in each new login session when needed:

```zsh
ssh-add ~/.ssh/id_ed25519
```

Bootstrap release, private-repository, repair, and user-migration procedures
are in [WSL operations](docs/WSL-OPERATIONS.md).

### Codex WSL backend

After bootstrap or a user migration, shut down WSL, reopen NixOS, and confirm
that `id` reports `zane` before enabling Codex's WSL backend. The primary WSL
UID is permanently `1000`; rename the user without changing that UID. See
[WSL operations](docs/WSL-OPERATIONS.md) for the migration procedure.

## Layout

- `configurations/hosts/`: host identity and machine-local facts.
- `configurations/profiles/`: capability combinations.
- `modules/options/`: reusable `my.*` option interfaces.
- `modules/home/` and `modules/system/`: Home Manager and system adapters.
- `resources/`: versioned configuration deployed outside Nix.
- `secrets/`: encrypted SOPS data.

Read [Architecture](docs/ARCHITECTURE.md) before changing module boundaries.

## Neovim

Nix installs `nvim`; link the versioned configuration manually:

```zsh
mkdir -p ~/.config
ln -sfn "$PWD/resources/nvim" ~/.config/nvim
```

## Secrets

Secrets use SOPS with age. Read [secrets/README.md](secrets/README.md) before
creating or editing encrypted files. To edit one:

```zsh
just edit-secret secrets/common.yaml
```

Windows configuration is intentionally outside this repository.
