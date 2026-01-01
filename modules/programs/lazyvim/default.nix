{ config, lib, ... }:

let
  cfg = config.modules.lazyvim;
in {
  options.modules.lazyvim.enable = lib.mkEnableOption "LazyVim configuration";

  config = lib.mkIf cfg.enable {
    xdg.configFile."lazyvim".source = ./config;
  };
}
