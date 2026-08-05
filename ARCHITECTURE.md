# Architecture

## Composition model

Each flake output composes configuration through explicit imports:

```text
configuration host + profile fragments + focused options + home/system adapters
```

- `configurations/hosts/` owns machine identity, facts, and machine-local preferences.
- `configurations/profiles/` supplies values and combinations. A profile does not define
  option schemas or import unrelated implementations.
- `modules/options/` owns pure, reusable Nix option interfaces.
- `modules/home/` is Home Manager-only implementation, including `gui`.
- `modules/system/` owns Darwin and NixOS substrate configuration and system adapters.
- `modules/flake-parts/` owns flake output composition only; it is neither a
  Home Manager nor a system implementation layer.
- `modules/home/{services,connectivity,data}/` owns Home Manager runtime adapters.
  Profiles
  declare data contracts; hosts supply machine-local paths, device roles, and
  destinations when an adapter needs them.

On macOS, nix-darwin and `nix-homebrew` own only the Homebrew installation
substrate. The Darwin Home Manager adapter owns the generated Brewfile and its
user-level synchronization; desktop, connectivity, and services adapters
contribute packages through `my.homebrew`.

## Flake composition and input partitions

The root flake uses flake-parts for explicit output composition. Its modules
live in `modules/flake-parts/`, but they must not auto-discover configuration
modules or define Home Manager, Darwin, or NixOS behavior.

- `base.nix` exports the supported MacBook, WSL, and standalone Home Manager
  outputs and their shared stable inputs.
- `development.nix` belongs to the `dev` partition and exports the formatter,
  dev shell, and `nix-fast-build` package.
- `dev/flake.nix` has a separate lock for development-only inputs. They are not
  root inputs and therefore cannot block deployment-output evaluation.

Future host-specific optional dependency graphs belong in their own partition
only when a real host consumes them. For example, a future Linux desktop
partition may own Apple fonts and GUI-only inputs. Do not add dormant inputs to
the root graph merely to preserve a future possibility.

## Options boundary

An interface under `modules/options/` may declare options, types, defaults, and
interface-level assertions. It must not install packages, create activation
steps, refer to `pkgs` or `inputs`, or use Home Manager-only state such as XDG
paths.

Interfaces are imported explicitly by their consumers. Do not add a global
`modules/options/default.nix` that imports every interface: each target should
evaluate only the interfaces it needs.

Feature domains may expose a parent `enable` and independently configurable
child features. A child may be declared as enabled while its parent is false,
which permits profiles to state intended capabilities before enabling a domain.
The adapter and any base implementation load only when the parent is enabled;
the parent switch is the domain's single effective lifecycle boundary.

For example, `modules/options/ai.nix` is consumed by both the Home Manager AI
implementation and the GUI Home Manager adapter. AI CLI behavior remains in
`modules/home/ai/home.nix`; GUI casks remain in `modules/home/gui/ai/homebrew.nix`.

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

## Open design questions

The helper currently named `lib/domain.nix` defines a `my.*` option subtree,
optional base implementation, and independently selectable features. Its name
may be confused with a DDD business domain. Candidate replacements include
`capability.nix`, `feature-set.nix`, and `module-family.nix`; no rename is
decided until the chosen word better describes this composition role.

Likewise, `my.*` remains the public personal-environment DSL because it gives
all options a clear ownership boundary. The helper's `namespace` argument is
an implementation detail that maps a module to that option path. We should
revisit whether `namespace` should be renamed to `optionPath`, or whether the
helper should receive a structured path, if the current string-based form
becomes harder to navigate or refactor. Neither question changes the public
`my.*` interface today.
