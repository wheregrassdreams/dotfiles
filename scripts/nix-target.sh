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

detect_platform() {
  case "$(uname -s)" in
    Darwin)
      printf '%s\n' darwin
      ;;
    Linux)
      if [[ -n "${WSL_INTEROP:-}" ]] || {
        [[ -r /proc/sys/kernel/osrelease ]] && grep -qiE '(microsoft|wsl)' /proc/sys/kernel/osrelease;
      }; then
        printf '%s\n' wsl
      else
        die "unsupported Linux environment; this repository only supports NixOS WSL"
      fi
      ;;
    *)
      die "unsupported platform: $(uname -s)"
      ;;
  esac
}

platform="$(detect_platform)"
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

describe() {
  printf 'platform=%s\nruntime_host=%s\ncanonical_host=%s\nuser=%s\nsystem_target=%s\nhome_target=%s\n' \
    "$platform" "$runtime_host" "$canonical_host" "$current_user" "$canonical_host" "${current_user}@${canonical_host}"
}

run_system() {
  local operation="$1"

  case "$platform" in
    darwin)
      case "$operation" in
        build) exec darwin-rebuild build --flake "$system_ref" ;;
        switch) exec darwin-rebuild switch --flake "$system_ref" ;;
        test) die "test is only available for NixOS systems" ;;
        *) die "unsupported system operation: $operation" ;;
      esac
      ;;
    wsl)
      case "$operation" in
        build) exec nixos-rebuild build --flake "$system_ref" ;;
        test) exec sudo nixos-rebuild test --flake "$system_ref" ;;
        switch) exec sudo nixos-rebuild switch --flake "$system_ref" ;;
        *) die "unsupported system operation: $operation" ;;
      esac
      ;;
  esac
}

run_home() {
  local operation="$1"

  case "$operation" in
    build)
      exec nix run --inputs-from "$repo" home-manager -- build --flake "$home_ref"
      ;;
    switch)
      exec nix run --inputs-from "$repo" home-manager -- switch --flake "$home_ref"
      ;;
    *)
      die "unsupported Home Manager operation: $operation"
      ;;
  esac
}

run_fast_build() {
  local attr

  case "$platform" in
    darwin)
      attr="darwinConfigurations.${canonical_host}.system"
      ;;
    wsl)
      attr="nixosConfigurations.${canonical_host}.config.system.build.toplevel"
      ;;
  esac

  exec nix run "$repo#nix-fast-build" -- --no-nom --skip-cached --flake "$repo#$attr"
}

case "$action" in
  describe)
    describe
    ;;
  build|test|switch)
    run_system "$action"
    ;;
  build-home)
    run_home build
    ;;
  switch-home)
    run_home switch
    ;;
  fast-build)
    run_fast_build
    ;;
  *)
    die "unsupported action: $action"
    ;;
esac
