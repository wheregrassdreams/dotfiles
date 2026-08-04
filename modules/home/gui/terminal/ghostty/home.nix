{ config, lib, ... }:
let cfg = config.my.gui.terminal.ghostty;
in {
  imports = [
    ../../../../options/gui/terminal.nix
    ../../../../options/homebrew.nix
  ];
  config = lib.mkIf cfg.enable {
    my.homebrew.casks = [ "ghostty" ];
    xdg.configFile."ghostty/config".source = ./config;
    xdg.configFile."ghostty/shaders".source = ./shaders;
  };
}
