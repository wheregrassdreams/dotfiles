# Secrets layout

Use sops-nix with age. Store encrypted files under `secrets/`; `.sops.yaml`
defines the recipients used for encryption.

Recipients are public encryption policy, not host configuration. Keep private
age identities and SSH private keys on the machine; never commit them. A host
may provide the path to its local decryption identity to the Home Manager
secrets adapter without exposing that key in Nix.

Suggested layout:

- `secrets/common.yaml` (shared across environments)
- `secrets/hosts/<host>.yaml`
- `secrets/users/<user>.yaml`
- `secrets/apps/<app>.yaml`

## Add an age identity

Run once on a machine that needs to decrypt secrets:

```zsh
age-keygen -o ~/.config/sops/age/keys.txt
```

To use the SSH public key as an additional recipient, print its age recipient
and add the result to `.sops.yaml`:

```zsh
ssh-to-age -i ~/.ssh/id_ed25519.pub
```

## Edit a secret

Create or edit an encrypted file with:

```zsh
just edit-secret secrets/common.yaml
```

The command uses the repository's SOPS configuration and leaves decrypted
content only in SOPS's temporary editor file.
