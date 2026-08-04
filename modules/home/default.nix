{ inputs, ... }:
{
  imports = [
    inputs.nix-index-database.homeModules.nix-index
    ./base
    ./shell
    ./terminal
    ./tools
    ./development
    ./ai
    ./git
    ./ssh
    ./secrets
  ];
}
