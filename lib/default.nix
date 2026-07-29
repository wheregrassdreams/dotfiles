{
  lib,
  nixpkgs,
  inputs,
  self,
  overlays,
}:
let
  dotfilesLib = {
    importAll = import ./import-all.nix { inherit lib; };
    domain = import ./domain.nix { inherit lib; };
    mkHost = import ./mk-host.nix { inherit nixpkgs inputs self overlays dotfilesLib; };
    mkHome = import ./mk-home.nix { inherit nixpkgs inputs self overlays dotfilesLib; };
  };
in dotfilesLib
