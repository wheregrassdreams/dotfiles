{ config, lib, pkgs, ... }:

let
  cfg = config.modules.eza;
in {
  options.modules.eza.enable = lib.mkEnableOption "eza configuration";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.eza ];
    xdg.configFile."eza".source = ./config;
  };
}
