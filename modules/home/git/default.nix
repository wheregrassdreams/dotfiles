{ ... }:
{
  imports = [
    ../../options/git.nix
    ../../options/identity.nix
    ./base.nix
    ./gitea.nix
    ./github.nix
    ./gitlab.nix
    ./lazygit.nix
  ];
}
