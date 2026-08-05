{ inputs, ... }:
let
  inherit (inputs) self nixpkgs;

  overlays = [
    inputs.nur.overlays.default
    inputs.llm-agents.overlays.default
  ];

  dotfilesLib = import ../../lib {
    lib = nixpkgs.lib;
    inherit
      nixpkgs
      inputs
      self
      overlays
      ;
  };
in
{
  flake = {
    lib = nixpkgs.lib.extend (
      _: _: {
        dotfiles = dotfilesLib;
      }
    );

    darwinConfigurations.macbook = dotfilesLib.mkHost (import ../../configurations/hosts/macbook);
    nixosConfigurations.wsl = dotfilesLib.mkHost (import ../../configurations/hosts/wsl);
    homeConfigurations.zanelu-macbook = dotfilesLib.mkHome (import ../../configurations/hosts/macbook);
  };
}
