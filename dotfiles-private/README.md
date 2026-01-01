# dotfiles-private (stub)

This is a public stub that provides the same Nix module interface as the
private secrets repository. It supplies safe defaults so the public repo
builds without access to private secrets.

To use your real private secrets repository, edit `flake.nix` in the root
of this repo and point `dotfiles-private` at your private Git URL.

This repo expects your encrypted secrets at
`dotfiles-private/secrets/secrets.yaml` when using sops-nix.
