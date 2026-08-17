#!/usr/bin/env bash
set -Eeuo pipefail

[[ $# -eq 1 ]] || {
  printf 'usage: %s FILE\n' "$(basename "$0")" >&2
  exit 2
}

source_path="$1"
timestamp="$(date '+%Y%m%d-%H%M%S')"
backup_path="${source_path}.hm-backup-${timestamp}"
suffix=1

while [[ -e "$backup_path" || -L "$backup_path" ]]; do
  backup_path="${source_path}.hm-backup-${timestamp}.${suffix}"
  suffix=$((suffix + 1))
done

mv -- "$source_path" "$backup_path"
printf 'Backed up %s to %s\n' "$source_path" "$backup_path" >&2
