{ config, lib, pkgs, ... }:

let
  cfg = config.modules.tmux;
in {
  options.modules.tmux.enable = lib.mkEnableOption "tmux configuration";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.tmux ];
    home.file.".tmux.conf".source = ./config/tmux.conf;
    xdg.configFile."tmux".source = ./config;
  };
}
