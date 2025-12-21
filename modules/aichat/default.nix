{ config, lib, pkgs, ... }:

let
  cfg = config.modules.aichat;
in {
  options.modules.aichat.enable = lib.mkEnableOption "aichat configuration";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.aichat ];
    xdg.configFile."aichat".source = ./config;
  };
}
