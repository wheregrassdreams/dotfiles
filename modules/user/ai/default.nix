{ dotfilesLib, lib, config, pkgs, inputs, system, ... }@ctx:
let
  contract = import ./contract.nix { inherit lib; };
in
dotfilesLib.domain ctx (contract // {
  settings.dataHome = lib.mkOption {
    type = lib.types.str;
    default = "${config.xdg.dataHome}/agent";
    description = "shared data directory for AI agent resources";
  };
  base = ./base.nix;
})
