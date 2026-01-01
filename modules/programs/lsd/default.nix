{ config, lib, pkgs, ... }:

let
  cfg = config.modules.lsd;
in {
  options.modules.lsd.enable = lib.mkEnableOption "lsd configuration";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.lsd ];
    xdg.configFile."lsd".source = ./config;
  };
}
