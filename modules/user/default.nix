{ inputs, ... }:
{
  imports = [
    inputs.nix-index-database.homeModules.nix-index
    ./foundation
    ./shell
    ./terminal
    ./cli
    ./dev
    ./ai
    ./git
    ./ssh
    ./secrets
  ];
}
