# Explicit module registry. Adding a file never changes a host by itself.
{
  imports = [
    ./me.nix
    ./xdg.nix
    ./cli.nix
    ./cli-base.nix
    ./cli-data.nix
    ./cli-media.nix
    ./cli-ai.nix
    ./dev.nix
    ./dev-nix.nix
    ./dev-go.nix
    ./dev-javascript.nix
    ./dev-rust.nix
    ./dev-python-data.nix
    ./git.nix
    ./ssh.nix
    ./secrets.nix
    ./work.nix
    ./nix-index.nix
    ./zsh
    ./tmux
    ./ghostty
    ./bundles.nix
  ];
}
