# Secrets layout

Use sops-nix with age. Store encrypted files under `secrets/` and use
`.sops.yaml` recipients for encryption.

Suggested files:
- `secrets/common.yaml` (shared across environments)
- `secrets/hosts/<host>.yaml`
- `secrets/users/<user>.yaml`
- `secrets/apps/<app>.yaml`

Example setup (run once):
1) `age-keygen -o ~/.config/sops/age/keys.txt`
2) `ssh-to-age -i ~/.ssh/id_ed25519.pub`
3) Replace the recipients in `.sops.yaml`

Encrypt a new file:
`sops --encrypt --in-place secrets/common.yaml`

There is also a easier way to edit a file with `./scripts/edit-secrets.sh`
`./scripts/edit-secrets.sh secrets/common.yaml`
