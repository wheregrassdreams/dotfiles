{ config, lib, pkgs, ... }:

let
  cfg = config.modules.zellij;
in {
  options.modules.zellij.enable = lib.mkEnableOption "Zellij configuration";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.zellij ];
    xdg.configFile."zellij".source = ./config;
  };
}
