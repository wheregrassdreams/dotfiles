{ config, lib, ... }:
let cfg = config.dotfiles.desktop.terminal.ghostty;
in {
  imports = [
    ../default.nix
    ../../../options/homebrew.nix
  ];
  config = lib.mkIf cfg.enable {
    dotfiles.homebrew.casks = [ "ghostty" ];
    xdg.configFile."ghostty/config".source = ./config;
    xdg.configFile."ghostty/shaders".source = ./shaders;
  };
}
