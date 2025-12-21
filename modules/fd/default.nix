{ config, lib, pkgs, ... }:

let
  cfg = config.modules.fd;
in {
  options.modules.fd.enable = lib.mkEnableOption "fd configuration";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.fd ];
    xdg.configFile."fd".source = ./config;
  };
}
