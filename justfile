# Repository-local command entry points. Run `just --list` to discover them.

repo := justfile_directory()

default:
    @just --list

# Evaluate all declared flake checks without changing the active machine.
check:
    nix flake check "path:{{ repo }}" --no-write-lock-file --no-eval-cache

# Format Nix and shell files without changing the active machine.
fmt:
    cd "{{ repo }}" && nix fmt

# Enter the pinned development environment.
dev:
    nix develop "{{ repo }}"

# Run the same pre-commit checks as `git commit` for staged files, without creating a commit.
check-staged:
    nix develop "{{ repo }}" --command pre-commit run

# Build the system output for the current supported platform without activating it.
build:
    bash "{{ repo }}/scripts/nix-target.sh" build "{{ repo }}"

# Test the NixOS system output without changing the active generation.
test:
    bash "{{ repo }}/scripts/nix-target.sh" test "{{ repo }}"

# Apply the system output for the current supported platform.
switch:
    bash "{{ repo }}/scripts/nix-target.sh" switch "{{ repo }}"

# Build, but do not activate, the standalone Home Manager configuration for the current user and host.
build-home:
    bash "{{ repo }}/scripts/nix-target.sh" build-home "{{ repo }}"

# Apply only the standalone Home Manager configuration for the current user and host.
switch-home:
    bash "{{ repo }}/scripts/nix-target.sh" switch-home "{{ repo }}"

# Use nix-fast-build for the current supported system output. Intended for CI or remote builders.
fast-build:
    bash "{{ repo }}/scripts/nix-target.sh" fast-build "{{ repo }}"

# Update the declared flake inputs used by the personal configuration.
update:
    nix flake update nixpkgs nixpkgs-unstable nix-darwin home-manager nix-homebrew --flake "{{ repo }}"

# Collect unreachable user generations only.
gc-user:
    nix-collect-garbage -d

# Collect unreachable system generations; this requires root privileges.
gc-system:
    sudo nix-collect-garbage -d

# Optimise the local Nix store without deleting generations.
store-optimise:
    nix store optimise

# Edit an encrypted SOPS file, for example: `just edit-secret secrets/common.yaml`.
edit-secret secret_file:
    "sops edit" "{{ secret_file }}"
