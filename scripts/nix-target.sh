#!/usr/bin/env bash
set -Eeuo pipefail

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

[[ $# -eq 2 ]] || die "usage: $(basename "$0") ACTION REPOSITORY"

action="$1"
repo="$2"

[[ -f "$repo/flake.nix" ]] || die "repository does not contain flake.nix: $repo"

case "$(uname -s)" in
  Darwin)
    platform=darwin
    ;;
  Linux)
    if [[ -n "${WSL_INTEROP:-}" ]] || {
      [[ -r /proc/sys/kernel/osrelease ]] && grep -qiE '(microsoft|wsl)' /proc/sys/kernel/osrelease;
    }; then
      platform=wsl
    else
      die "unsupported Linux environment; this repository only supports NixOS WSL"
    fi
    ;;
  *)
    die "unsupported platform: $(uname -s)"
    ;;
esac

runtime_host="$(hostname -s)"
current_user="$(id -un)"
canonical_host="$runtime_host"

# The existing WSL system still reports the legacy hostname `nixos`, while its
# bootstrap and flake system output use `wsl`. Keep this one compatibility
# mapping until the runtime hostname is migrated.
if [[ "$platform" == wsl && "$runtime_host" == nixos ]]; then
  canonical_host=wsl
  printf 'warning: WSL hostname "nixos" is temporarily mapped to canonical host "wsl"\n' >&2
fi

system_ref="$repo#$canonical_host"
home_ref="$repo#${current_user}@${canonical_host}"

case "$action:$platform" in
  describe:*)
    printf 'platform=%s\nruntime_host=%s\ncanonical_host=%s\nuser=%s\nsystem_target=%s\nhome_target=%s\n' \
      "$platform" "$runtime_host" "$canonical_host" "$current_user" "$canonical_host" "${current_user}@${canonical_host}"
    ;;
  build:darwin)
    exec darwin-rebuild build --flake "$system_ref"
    ;;
  switch:darwin)
    exec darwin-rebuild switch --flake "$system_ref"
    ;;
  test:darwin)
    die "test is only available for NixOS systems"
    ;;
  build:wsl)
    exec nixos-rebuild build --flake "$system_ref"
    ;;
  test:wsl)
    exec sudo nixos-rebuild test --flake "$system_ref"
    ;;
  switch:wsl)
    exec sudo nixos-rebuild switch --flake "$system_ref"
    ;;
  build-home:*)
    exec nix run --inputs-from "$repo" home-manager -- build --flake "$home_ref"
    ;;
  switch-home:*)
    exec nix run --inputs-from "$repo" home-manager -- switch --flake "$home_ref" \
      -B "${repo}/scripts/home-manager-backup.sh"
    ;;
  fast-build:darwin)
    exec nix run "$repo#nix-fast-build" -- --no-nom --skip-cached --flake "$repo#darwinConfigurations.${canonical_host}.system"
    ;;
  fast-build:wsl)
    exec nix run "$repo#nix-fast-build" -- --no-nom --skip-cached --flake "$repo#nixosConfigurations.${canonical_host}.config.system.build.toplevel"
    ;;
  *)
    die "unsupported action: $action"
    ;;
esac
