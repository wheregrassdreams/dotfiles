{ config, lib, pkgs, ... }:

let
  cfg = config.modules.btop;
in {
  options.modules.btop.enable = lib.mkEnableOption "btop configuration";

  config = lib.mkIf cfg.enable {
    programs.btop.enable = false;
    home.packages = [ pkgs.btop ];
    xdg.configFile."btop".source = ./config;
  };
}
