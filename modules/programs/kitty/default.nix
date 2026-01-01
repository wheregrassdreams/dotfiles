{ config, lib, pkgs, ... }:

let
  cfg = config.modules.kitty;
in {
  options.modules.kitty.enable = lib.mkEnableOption "kitty configuration";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.kitty ];
    xdg.configFile."kitty".source = ./config;
  };
}
