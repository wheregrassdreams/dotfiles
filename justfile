# Repository-local command entry points. Run `just --list` to discover them.

repo := justfile_directory()

default:
  @just --list

# Evaluate all declared flake checks without changing the active machine.
check:
  nix flake check "path:{{repo}}" --no-write-lock-file --no-eval-cache

# Format Nix and shell files without changing the active machine.
fmt:
  cd "{{repo}}" && nix fmt

# Enter the pinned development environment.
dev:
  nix develop "{{repo}}"

# Run the same pre-commit checks as `git commit` for staged files, without creating a commit.
check-staged:
  nix develop "{{repo}}" --command pre-commit run

# Build the system output for the current supported platform without activating it.
build:
  #!/usr/bin/env bash
  set -euo pipefail
  case "$(uname -s)" in
    Darwin) darwin-rebuild build --flake "{{repo}}#macbook" ;;
    Linux)
      grep -qiE '(microsoft|wsl)' /proc/sys/kernel/osrelease || {
        echo 'This repository only supports the Linux build through its WSL output.' >&2
        exit 1
      }
      nixos-rebuild build --flake "{{repo}}#wsl"
      ;;
    *) echo "Unsupported platform: $(uname -s)" >&2; exit 1 ;;
  esac

# Apply the system output for the current supported platform. This is intentionally explicit because it uses sudo.
switch:
  #!/usr/bin/env bash
  set -euo pipefail
  case "$(uname -s)" in
    Darwin) sudo darwin-rebuild switch --flake "{{repo}}#macbook" ;;
    Linux)
      grep -qiE '(microsoft|wsl)' /proc/sys/kernel/osrelease || {
        echo 'This repository only supports the Linux switch through its WSL output.' >&2
        exit 1
      }
      sudo nixos-rebuild switch --flake "{{repo}}#wsl"
      ;;
    *) echo "Unsupported platform: $(uname -s)" >&2; exit 1 ;;
  esac

# Build, but do not activate, the standalone MacBook Home Manager configuration.
build-home:
  nix run --inputs-from "{{repo}}" home-manager -- build --flake "{{repo}}#zanelu-macbook"

# Apply only the MacBook Home Manager configuration, including the Homebrew package sync.
switch-home:
  nix run --inputs-from "{{repo}}" home-manager -- switch --flake "{{repo}}#zanelu-macbook"

# Use nix-fast-build for the current supported system output. Intended for CI or remote builders.
fast-build:
  #!/usr/bin/env bash
  set -euo pipefail
  case "$(uname -s)" in
    Darwin) attr='darwinConfigurations.macbook.system' ;;
    Linux)
      grep -qiE '(microsoft|wsl)' /proc/sys/kernel/osrelease || {
        echo 'This repository only supports the Linux build through its WSL output.' >&2
        exit 1
      }
      attr='nixosConfigurations.wsl.config.system.build.toplevel'
      ;;
    *) echo "Unsupported platform: $(uname -s)" >&2; exit 1 ;;
  esac
  nix run "{{repo}}#nix-fast-build" -- --no-nom --skip-cached --flake "{{repo}}#${attr}"

# Edit an encrypted SOPS file, for example: `just edit-secret secrets/common.yaml`.
edit-secret secret_file:
  "{{repo}}/scripts/edit-secrets.sh" "{{secret_file}}"
