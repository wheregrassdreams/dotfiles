{ ... }:
{
  imports = [
    ../../options/git.nix
    ../../options/identity.nix
    ./base.nix
    ./gitea.nix
    ./gitlab.nix
    ./lazygit.nix
  ];
}
