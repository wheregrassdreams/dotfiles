{ config, lib, pkgs, ... }:

let
  cfg = config.modules.fish;
in {
  options.modules.fish.enable = lib.mkEnableOption "fish configuration";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.fish ];
    xdg.configFile."fish" = {
      source = ./config;
      recursive = true;
      force = true;
    };
  };
}
