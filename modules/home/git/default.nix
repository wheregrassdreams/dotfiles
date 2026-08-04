{ ... }:
{
  imports = [
    ../../options/git.nix
    ./base.nix
    ./gitea.nix
    ./github.nix
    ./gitlab.nix
    ./interactive.nix
  ];
}
