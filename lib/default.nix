{
  lib,
  nixpkgs,
  inputs,
  self,
  overlays,
}:
let
  dotfilesLib = {
    domain = import ./domain.nix { inherit lib; };
    feature.group = children: {
      _type = "dotfiles-feature-group";
      inherit children;
    };
    mkHost = import ./mk-host.nix { inherit nixpkgs inputs self overlays dotfilesLib; };
    mkHome = import ./mk-home.nix { inherit nixpkgs inputs self overlays dotfilesLib; };
  };
in dotfilesLib
