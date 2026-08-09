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

## Quick commands

`just` is the repository-local, discoverable command entry point. It is
installed as part of `my.tools.core` and complements the interactive shell
aliases; it does not replace them. Run `just --list` for the full list.

```zsh
just check
just fmt
just build
just switch-home
just switch
```

`build` and `switch` select the MacBook or WSL system output from the current
platform. `switch-home` remains intentionally separate: it applies only Home
Manager and synchronizes Homebrew packages. Use `just dev` for the pinned
developer environment. `just fmt` formats Nix and shell files, and `just
check-staged` runs the same pre-commit checks as `git commit` for staged files,
without creating a commit. The repository respects the existing Git
`core.hooksPath` instead of replacing its hook manager.

Destructive or privileged actions remain explicit: `switch` requires `sudo`;
package cleanup continues to require an explicit
`brew-sync --cleanup` or `brew-sync --zap` invocation.

## Direnv

This repository loads its pinned development environment automatically through
direnv. In a new clone or worktree, trust the checked-in `.envrc` once:

```zsh
direnv allow
```

Afterward, entering the repository loads the default flake devShell from the
development input partition, including
the development tools and generated pre-commit configuration. `just dev`
remains the explicit fallback when direnv is unavailable. The project layout is
stored under the XDG direnv cache rather than in the repository; `.direnv/` is
ignored as a safeguard.

For Homebrew formulae, casks, and taps, use the Home Manager command above.
`darwin-rebuild` only bootstraps Homebrew itself and applies macOS system
configuration. The generated Brewfile synchronizes declared packages without
updating, upgrading, or removing undeclared packages by default. Use
`brew-sync --update`, `brew-sync --upgrade`, `brew-sync --cleanup`, or
`brew-sync --zap` only when that behavior is intentional.

## First bootstrap

Install Determinate Nix on macOS, clone this repository, then apply the
MacBook output.

### Install NixOS WSL from Windows

Run the following in PowerShell to download a pinned installer script to a
temporary file and install the latest NixOS-WSL release. It uses
`wsl --install --from-file` when available and falls back to `wsl --import` for
older WSL versions. The default installation location is
`%LOCALAPPDATA%\WSL\NixOS`; pass `-InstallLocation 'E:\WSL\NixOS'` to place the
distribution elsewhere.

```powershell
$installer = Join-Path ([System.IO.Path]::GetTempPath()) 'install-nixos-wsl.ps1'; Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/wheregrassdreams/dotfiles/bootstrap-v1/scripts/install-nixos-wsl.ps1' -OutFile $installer; & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installer -InstallLocation 'E:\WSL\NixOS'; $status = $LASTEXITCODE; Remove-Item -LiteralPath $installer -Force; exit $status
```

The installer refuses to overwrite an existing distribution or installation
directory. Add `-SetDefault` only when NixOS should become the default WSL
distribution. Once it finishes, open `wsl -d NixOS` and continue with the NixOS
bootstrap below.

### Fresh NixOS WSL bootstrap

On a fresh NixOS WSL installation, sign in as the installer user and run the
following single command. It downloads the versioned bootstrap script to a
temporary file instead of piping network content directly to a shell. The
script temporarily obtains Git through Nix, builds and tests `.#wsl`, switches
the system, then moves that same checkout into the permanent zane-owned
location at `~/nix-config`.

The initial download and clone use HTTPS because a fresh WSL installation has
no GitHub key. After the first switch, the script offers to create a
passphrase-protected key at `~/.ssh/id_ed25519`, authenticate in the
browser, upload its public half, verify SSH over port 443, and change `origin`
to `git@github.com:wheregrassdreams/dotfiles.git`. Decline the prompt or pass
`--skip-github-ssh` to retain HTTPS temporarily.

```bash
tmp="$(mktemp)"; curl --proto '=https' --tlsv1.2 -fsSL "https://raw.githubusercontent.com/wheregrassdreams/dotfiles/bootstrap-v1/scripts/bootstrap-nixos-wsl.sh" -o "$tmp" && bash "$tmp"; status=$?; rm -f "$tmp"; exit "$status"
```

The `bootstrap-v1` tag must be created and protected when this change is
released. Before making this repository private, move the same bootstrap
script to a separate public repository (for example,
`wheregrassdreams/nixos-bootstrap`) and change this command there; a private
repository cannot provide an unauthenticated raw bootstrap URL.

For a private GitHub repository, use the downloaded script with `--private`.
It uses temporary GitHub CLI HTTPS authentication for the initial clone, then
offers the same zane-owned SSH setup after switch. Neither the private key nor
GitHub CLI credentials enter this repository.

After the script completes, run `wsl --shutdown` from Windows and reopen
NixOS. Daily use is from the permanent configuration checkout:

```zsh
cd ~/nix-config
sudo nixos-rebuild switch --flake .#wsl
```

The bootstrap command is safe to re-run: once `~/nix-config` exists as a Git
flake checkout, it reuses that checkout for build, test, and switch instead of
cloning or replacing it. Use `--repair` only when you intentionally need to
restore zane ownership of the checkout and reset the zane password.
For a locally prepared, not-yet-pushed checkout, pass `--source /absolute/path`
instead of cloning from GitHub. At completion, the script offers to run
`wsl.exe --shutdown`; if Windows interop is unavailable, run that command from
Windows PowerShell instead.

After reopening WSL, unlock the key once per login session:

```zsh
ssh-add ~/.ssh/id_ed25519
```

The NixOS SSH agent and GitHub SSH-over-443 host configuration are declared by
this repository. GitHub HTTPS Git URLs are rewritten to SSH for daily use; raw
bootstrap downloads remain HTTPS.

### Codex WSL backend and future user changes

After bootstrap, accept `wsl --shutdown`, reopen NixOS, verify `id` reports
`zane`, and only then re-enable Codex's WSL backend. This clears the previous
WSL process and makes the updated DrvFS mount options effective.

The primary WSL identity uses UID 1000. Usernames may change, but the primary
UID must not: DrvFS metadata records numeric ownership rather than usernames.
For a future rename, declare the new default user with UID 1000, update the WSL
default user, and keep the DrvFS mount UID at 1000. A genuine UID change still
requires a directed migration of the shared Codex state:

```bash
sudo chown -R --no-dereference NEW_USER:users /mnt/c/Users/<WindowsUser>/.codex
```

Run `wsl --shutdown`, confirm the new default user with `id`, and then enable
the Codex WSL backend. Do not recursively change ownership of the entire
Windows profile or drive.

NixOS WSL is built from the `wsl` output; its tarball builder is available at
`.#nixosConfigurations.wsl.config.system.build.tarballBuilder`.

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
