{ config, lib, pkgs, ... }:

let
  cfg = config.modules.neovide;
in {
  options.modules.neovide.enable = lib.mkEnableOption "Neovide configuration";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.neovide ];
    xdg.configFile."neovide".source = ./config;
  };
}
