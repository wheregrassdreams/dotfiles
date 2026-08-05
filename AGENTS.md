# AGENTS.md

## Repository model

This is a Nix flake for the MacBook and NixOS WSL. Read
[`ARCHITECTURE.md`](ARCHITECTURE.md) before changing module boundaries. Keep the
composition chain explicit:

```text
flake output -> configurations/hosts -> configurations/profiles -> modules/options -> modules/home or modules/system
```

- `configurations/hosts/` owns machine identity, platform facts, and machine-local settings.
- `configurations/profiles/` selects capabilities; it must not contain host facts or secrets.
- `modules/options/` owns pure reusable option interfaces; implementations
  live in focused Home Manager, Darwin, or NixOS adapters.
- `modules/flake-parts/` owns flake output composition and input partitions;
  it is not a Home Manager or system adapter directory.
- `resources/` holds versioned configuration deliberately deployed outside Nix.
- `secrets/` holds encrypted SOPS data only.

The supported outputs are `darwinConfigurations.macbook`,
`nixosConfigurations.wsl`, and `homeConfigurations.zanelu-macbook`.

## Local development

```zsh
nix flake check 'path:.' --no-write-lock-file --no-eval-cache
darwin-rebuild switch --flake .#macbook
sudo nixos-rebuild switch --flake .#wsl
home-manager switch --flake .#zanelu-macbook
```

On macOS, `darwin-rebuild` owns OS/bootstrap changes. Formulae, casks, taps,
and Homebrew service lifecycle are synchronized by `home-manager switch`.
`brew-sync --cleanup` and `brew-sync --zap` are explicit destructive actions;
never make undeclared-package cleanup automatic without a requested change.

Do not claim a host is usable merely because evaluation succeeds. A rebuild
must be followed by host-appropriate boot, service, and recovery verification.

## Module conventions

- Register imports explicitly. Do not reintroduce directory scanning or
  implicit module discovery.
- Keep development-only inputs in the `dev` partition under
  `modules/flake-parts/dev/`; do not move optional or experimental inputs into
  the root input graph without a current base-output consumer.
- `modules/home` is Home Manager-only; `modules/system` is Darwin/NixOS-only.
  Neither layer imports the other; both import focused interfaces from
  `modules/options`.
- Put local service lifecycle and connectivity adapters under the matching
  `modules/home` or `modules/system` domain; each imports only its contract.
- `my.services` owns local processes and client tools only. It never
  owns durable service data, backups, or restoration.
- Keep `modules/home/editor` as a placeholder until it gains a real capability.
- Use `my.paths` for named locations; define machine-specific locations
  in host facts rather than making unrelated profiles depend on each other.

## Secrets and non-Nix assets

Use SOPS/age for secrets and never add plaintext credentials. Neovim remains a
manual symlink from `resources/nvim`. Windows configuration has moved to
`/Users/zanelu/Workspace/code/projects/windows-config`; do not add it back to
this repository.
