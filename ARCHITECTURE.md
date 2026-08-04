# Architecture

## Composition model

Each flake output composes configuration through explicit imports:

```text
host facts + target profile fragments + platform adapters + focused options
```

- `hosts/` owns machine identity, facts, and machine-local preferences.
- `profiles/` supplies values and combinations. A profile does not define
  option schemas or import unrelated implementations.
- `modules/options/` owns pure, reusable Nix option interfaces.
- `modules/user/` is Home Manager-only implementation.
- `modules/desktop/` owns desktop platform adapters; its Darwin modules may
  import an option interface but never a Home Manager implementation.
- `modules/services/` and `modules/connectivity/` own runtime adapters and
  import only the focused interface they require.
- `modules/data/` owns backup, synchronization, and export adapters. Profiles
  declare data contracts; hosts supply machine-local paths, device roles, and
  destinations when an adapter needs them.
- `modules/platform/` owns NixOS and nix-darwin substrate configuration.

On macOS, nix-darwin and `nix-homebrew` own only the Homebrew installation
substrate. The Darwin Home Manager adapter owns the generated Brewfile and its
user-level synchronization; desktop, connectivity, and services adapters
contribute packages through `my.homebrew`.

## Options boundary

An interface under `modules/options/` may declare options, types, defaults, and
interface-level assertions. It must not install packages, create activation
steps, refer to `pkgs` or `inputs`, or use Home Manager-only state such as XDG
paths.

Interfaces are imported explicitly by their consumers. Do not add a global
`modules/options/default.nix` that imports every interface: each target should
evaluate only the interfaces it needs.

For example, `modules/options/ai.nix` is consumed by both the Home Manager AI
implementation and the Darwin AI adapter. AI CLI behavior remains in
`modules/user/ai/home.nix`; GUI casks remain in
`modules/desktop/ai/darwin.nix`.

`modules/options/data.nix` describes data ownership and recovery contracts; it
does not select or run backup tooling. Synchronization improves availability
but is not a backup, because deletion or corruption can propagate. Service
data must be exported consistently before backup: a live database directory is
not itself a recoverable backup. Tool-specific behavior such as Syncthing,
Restic, or rclone belongs in a future focused adapter with an independently
verified restore procedure.

## Performance boundary

Directory names do not affect build cost; a target's import and derivation
closure do. Keep outputs small by following these rules:

- split profile fragments by consumer when a value is only relevant to Home
  Manager or a system adapter;
- do not import Home Manager implementation from a system adapter, or system
  implementation from Home Manager;
- avoid directory scanning and aggregate registries;
- make platform adapters import only their local runtime dependencies and the
  matching interface.

Validate both correctness and closure changes with `nix flake check`, focused
`nix eval`, and dry-run builds before switching a machine.
