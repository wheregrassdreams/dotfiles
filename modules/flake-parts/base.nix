{ inputs, ... }:
let
  inherit (inputs) self nixpkgs;
  inherit (nixpkgs) lib;

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

  macbook = import ../../configurations/hosts/macbook;
  wsl = import ../../configurations/hosts/wsl;

  mkHostOutputs =
    name: host:
    lib.recursiveUpdate
      (lib.setAttrByPath [
        (if host.isDarwin or false then "darwinConfigurations" else "nixosConfigurations")
        name
      ] (dotfilesLib.mkHost host))
      (lib.setAttrByPath [ "homeConfigurations" "${host.userName}@${name}" ] (dotfilesLib.mkHome host));

  hostOutputs = lib.foldl' lib.recursiveUpdate { } [
    (mkHostOutputs "macbook" macbook)
    (mkHostOutputs "wsl" wsl)
  ];
in
{
  flake = lib.recursiveUpdate hostOutputs {
    lib = lib.extend (
      _: _: {
        dotfiles = dotfilesLib;
      }
    );

    # Retain the old standalone Home Manager output while callers migrate to
    # the user@host identity form.
    homeConfigurations.zanelu-macbook = hostOutputs.homeConfigurations."zanelu@macbook";
  };
}
