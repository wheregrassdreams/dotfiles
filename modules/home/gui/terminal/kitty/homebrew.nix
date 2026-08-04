{ config, lib, ... }:
{
  imports = [
    ../../../../options/gui/terminal.nix
    ../../../../options/homebrew.nix
  ];

  config = lib.mkIf config.my.gui.terminal.kitty.enable {
    my.homebrew.casks = [ "kitty" ];
  };
}
