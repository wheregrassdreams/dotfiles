#!/usr/bin/env bash
# Bootstrap a fresh NixOS WSL installation from this repository.
# This script deliberately has no dependency on Git being preinstalled.
set -Eeuo pipefail

readonly DEFAULT_REPO="wheregrassdreams/dotfiles"
readonly DEFAULT_BRANCH="nix-config"
readonly DEFAULT_HOST="wsl"
readonly DEFAULT_TARGET="/home/zane/nix-config"

repo="$DEFAULT_REPO"
branch="$DEFAULT_BRANCH"
host="$DEFAULT_HOST"
target="$DEFAULT_TARGET"
private_repo=false
repair=false
skip_github_ssh=false
source_override=""
tmp_dir=""

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Bootstrap a fresh NixOS WSL installation from a GitHub repository.

Options:
  --repo OWNER/REPO   GitHub repository (default: $DEFAULT_REPO)
  --branch BRANCH     Git branch to clone (default: $DEFAULT_BRANCH)
  --host HOST         nixosConfigurations target (default: $DEFAULT_HOST)
  --target PATH       Final zane-owned checkout (default: $DEFAULT_TARGET)
  --source PATH       Use an existing local Git flake for the first installation
  --private           Authenticate with GitHub CLI before cloning a private repo
  --skip-github-ssh   Do not configure zane's GitHub SSH key after first switch
  --repair            Repair checkout ownership, then reset the zane password
  -h, --help          Show this help
EOF
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

cleanup() {
  if [[ -n "$tmp_dir" && -d "$tmp_dir" ]]; then
    rm -rf -- "$tmp_dir"
  fi
}
trap cleanup EXIT

configure_github_ssh() {
  local answer

  printf '\nConfigure GitHub SSH for zane now? [Y/n] '
  read -r answer
  if [[ -n "$answer" && ! "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    printf 'GitHub SSH setup skipped; origin remains HTTPS.\n'
    return
  fi

  printf '\nConfiguring a dedicated, passphrase-protected GitHub SSH key for zane...\n'
  if ! sudo -u zane -H nix shell "${nix_features[@]}" nixpkgs#git nixpkgs#gh nixpkgs#openssh \
    --command bash -s -- "$repo" "$target" <<'ZANE_SSH_SETUP'
set -Eeuo pipefail

repo="$1"
target="$2"
key_dir="$HOME/.ssh"
key_file="$key_dir/id_ed25519_github_wsl"
public_key_file="$key_file.pub"

install -d -m 0700 "$key_dir"
if [[ ! -f "$key_file" ]]; then
  printf 'Create a passphrase for %s.\n' "$key_file"
  ssh-keygen -t ed25519 -a 64 -f "$key_file" -C "$(id -un)@$(hostname)-wsl"
fi
[[ -f "$public_key_file" ]] || {
  printf 'error: public key is missing: %s\n' "$public_key_file" >&2
  exit 1
}
chmod 0600 "$key_file"
chmod 0644 "$public_key_file"

gh auth login --web --git-protocol ssh --skip-ssh-key

public_key="$(<"$public_key_file")"
github_keys="$(gh api --paginate user/keys --jq '.[].key')"
if ! grep -Fqx "$public_key" <<<"$github_keys"; then
  gh ssh-key add "$public_key_file" --title "NixOS WSL $(hostname)"
fi

eval "$(ssh-agent -s)" >/dev/null
trap 'ssh-agent -k >/dev/null' EXIT
ssh-add "$key_file"
if ssh -T git@github.com; then
  :
else
  ssh_status=$?
  [[ "$ssh_status" -eq 1 ]] || exit "$ssh_status"
fi
git ls-remote "git@github.com:${repo}.git" HEAD >/dev/null
git -C "$target" remote set-url origin "git@github.com:${repo}.git"
ZANE_SSH_SETUP
  then
    printf 'GitHub SSH is ready; origin now uses SSH.\n'
  else
    printf 'GitHub SSH setup did not finish; origin remains HTTPS. Configure it later with gh auth login.\n' >&2
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) repo="${2:?--repo requires OWNER/REPO}"; shift 2 ;;
    --branch) branch="${2:?--branch requires a branch}"; shift 2 ;;
    --host) host="${2:?--host requires a host}"; shift 2 ;;
    --target) target="${2:?--target requires a path}"; shift 2 ;;
    --source) source_override="${2:?--source requires a path}"; shift 2 ;;
    --private) private_repo=true; shift ;;
    --skip-github-ssh) skip_github_ssh=true; shift ;;
    --repair) repair=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1" ;;
  esac
done

[[ "$repo" =~ ^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$ ]] || die "--repo must be OWNER/REPO"
[[ "$branch" =~ ^[A-Za-z0-9._/-]+$ ]] || die "--branch contains unsupported characters"
[[ "$host" =~ ^[A-Za-z0-9._-]+$ ]] || die "--host contains unsupported characters"
[[ "$target" = /* ]] || die "--target must be an absolute path"
[[ -z "$source_override" || "$source_override" = /* ]] || die "--source must be an absolute path"
[[ "$(id -u)" -ne 0 ]] || die "run this as a normal WSL user, not root"
grep -qiE '(microsoft|wsl)' /proc/sys/kernel/osrelease || die "this script only supports WSL"
command -v curl >/dev/null || die "curl is required"
command -v nix >/dev/null || die "nix is required"
command -v sudo >/dev/null || die "sudo is required"
curl --proto '=https' --tlsv1.2 -fsSI --connect-timeout 10 https://github.com >/dev/null \
  || die "cannot reach GitHub over HTTPS"

first_install=true
source_dir=""
if [[ -e "$target" || -L "$target" ]]; then
  [[ -d "$target" && ! -L "$target" ]] || die "target must be a directory path: $target"
  if [[ -n "$(find "$target" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]; then
    [[ -f "$target/flake.nix" && -d "$target/.git" ]] \
      || die "existing target is not a Git flake checkout: $target"
    first_install=false
    source_dir="$target"
  fi
fi

if [[ -n "$source_override" ]]; then
  "$first_install" || die "--source cannot be used when the target checkout already exists"
  [[ -d "$source_override/.git" && -f "$source_override/flake.nix" ]] \
    || die "--source must be a local Git flake checkout: $source_override"
  source_dir="$source_override"
fi

printf 'Bootstrap plan:\n'
printf '  repository: %s (branch %s)\n' "$repo" "$branch"
printf '  NixOS host: %s\n' "$host"
printf '  final checkout: %s\n' "$target"
if "$first_install"; then
  printf '  mode: first installation\n'
else
  printf '  mode: reuse existing checkout\n'
fi
if "$repair"; then
  printf '  repair: checkout ownership and zane password\n'
fi
if [[ -n "$source_override" ]]; then
  printf '  source: local checkout %s\n' "$source_override"
fi
printf '\nThis will build, test, and switch the NixOS configuration. Continue? [y/N] '
read -r answer
[[ "$answer" =~ ^[Yy]([Ee][Ss])?$ ]] || die "cancelled"

repo_url="https://github.com/$repo.git"
nix_features=(--extra-experimental-features 'nix-command flakes')

if "$first_install" && [[ -z "$source_override" ]] && "$private_repo"; then
  printf '\nAuthenticating with GitHub for the private repository...\n'
  nix shell "${nix_features[@]}" nixpkgs#git nixpkgs#gh --command gh auth login --web --git-protocol https
  nix shell "${nix_features[@]}" nixpkgs#git nixpkgs#gh --command gh auth setup-git
fi

if "$first_install"; then
  if [[ -z "$source_override" ]]; then
    tmp_dir="$(mktemp -d -t nixos-wsl-bootstrap.XXXXXXXX)"
    stage="$tmp_dir/source"
    printf '\nCloning bootstrap source...\n'
    nix run "${nix_features[@]}" nixpkgs#git -- clone --branch "$branch" --single-branch "$repo_url" "$stage" \
      || die "clone failed; use --private for a private GitHub repository"
    source_dir="$stage"
  fi
fi

printf '\nBuilding NixOS configuration...\n'
sudo nixos-rebuild build --flake "$source_dir#$host"
printf '\nTesting NixOS configuration...\n'
sudo nixos-rebuild test --flake "$source_dir#$host"
printf '\nSwitching NixOS configuration...\n'
sudo nixos-rebuild switch --flake "$source_dir#$host"

if "$first_install"; then
  printf '\nInstalling the permanent zane-owned checkout...\n'
  sudo install -d -m 0755 -o zane -g users "$(dirname "$target")"
  if [[ -d "$target" ]]; then
    sudo rmdir "$target" || die "target must be absent or an empty directory: $target"
  fi
  sudo mv "$source_dir" "$target"
  sudo chown -R zane:users "$target"
fi

if "$first_install" || "$repair"; then
  if "$repair" && ! "$first_install"; then
    printf '\nRepairing checkout ownership...\n'
    sudo chown -R zane:users "$target"
  fi
  printf '\nSet the zane password.\n'
  sudo passwd zane
fi

if "$first_install" && ! "$skip_github_ssh"; then
  configure_github_ssh
fi

cat <<EOF

Bootstrap complete.

From Windows, run:
  wsl --shutdown

Then reopen NixOS. It should log in as zane. Verify:
  id
  git --version
  git config user.name
  cmd.exe /c ver
  printf '%s\\n' "\$DOTFILES"
EOF

printf '\nShut down WSL now so the next launch starts as zane? [y/N] '
read -r shutdown_answer
if [[ "$shutdown_answer" =~ ^[Yy]([Ee][Ss])?$ ]]; then
  if command -v wsl.exe >/dev/null; then
    printf 'Shutting down WSL...\n'
    wsl.exe --shutdown || printf 'WSL shutdown failed; run "wsl --shutdown" from Windows PowerShell.\n' >&2
  else
    printf 'Run "wsl --shutdown" from Windows PowerShell.\n' >&2
  fi
fi
