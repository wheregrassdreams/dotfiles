# AGENTS.md

## Repository model

This is a Nix flake for the MacBook and NixOS WSL. Read
[`ARCHITECTURE.md`](docs/ARCHITECTURE.md) before changing module boundaries. Keep the
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

The canonical outputs are `darwinConfigurations.macbook`,
`nixosConfigurations.wsl`, `homeConfigurations.zanelu@macbook`, and
`homeConfigurations.zane@wsl`. `homeConfigurations.zanelu-macbook` remains a
temporary compatibility alias.

## Local development

```zsh
just check
just fmt
just build
just test
just switch
```

On macOS, `just switch` owns OS/bootstrap changes and its embedded Home
Manager activation. `just switch-home` is the standalone, user-environment
only path. Formulae, casks, taps, and Homebrew service lifecycle are included
in the embedded Home Manager activation.
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
manual symlink from `resources/nvim`. Windows configuration is out of scope for
this repository; do not add it here.
