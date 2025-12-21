{ config, lib, pkgs, ... }:

let
  cfg = config.modules.lazygit;
in {
  options.modules.lazygit.enable = lib.mkEnableOption "lazygit configuration";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.lazygit ];
    xdg.configFile."lazygit/config.yml".source = ./config/config.yml;
  };
}
