# WSL operations

This document contains maintenance procedures that are intentionally kept out
of the normal bootstrap path.

## Publishing a bootstrap release

The public install commands in the README use an immutable `bootstrap-v1` tag.
Before publishing those commands, create and push the tag, then protect it in
GitHub. Never move or reuse a published bootstrap tag; publish `bootstrap-v2`
for an incompatible launcher change.

```zsh
git tag -a bootstrap-v1 -m "NixOS WSL bootstrap v1"
git push origin bootstrap-v1
```

If this repository becomes private, move the launcher to a separate public
repository and update the README URL before changing visibility. A private
repository cannot supply an unauthenticated raw bootstrap download.

## Bootstrap options

The bootstrap is safe to re-run once `~/nix-config` is a Git flake checkout: it
rebuilds from that checkout without replacing it.

- `--private` uses temporary GitHub CLI HTTPS authentication for the initial
  clone, then configures the permanent checkout for SSH after switch.
- `--repair` restores `zane:users` ownership of the checkout and resets the
  `zane` password.
- `--source /absolute/path` uses a locally prepared Git checkout for a first
  installation instead of cloning it.
- `--skip-github-ssh` leaves `origin` on HTTPS temporarily.

Private keys and GitHub CLI credentials remain outside the repository.

## Stable WSL identity and Codex

The primary WSL account has UID `1000`. DrvFS stores numeric Linux ownership
metadata, so a rename must retain UID `1000`.

For a future rename:

1. Declare the new user with UID `1000` and make it the WSL default user.
2. Switch the system before removing the old account.
3. Shut down WSL, reopen it, and confirm the new identity with `id`.
4. Re-enable the Codex WSL backend only after the new default user is active.

A real UID change requires explicitly migrating only the affected Windows-side
state. For Codex:

```bash
sudo chown -R --no-dereference NEW_USER:users /mnt/c/Users/<WindowsUser>/.codex
```

Do not recursively change ownership of a whole Windows profile or drive.

The WSL tarball builder is available at:

```text
.#nixosConfigurations.wsl.config.system.build.tarballBuilder
```
