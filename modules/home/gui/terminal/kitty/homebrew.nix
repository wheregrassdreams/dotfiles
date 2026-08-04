{ config, lib, ... }:
{
  imports = [
    ../default.nix
    ../../../../options/homebrew.nix
  ];

  config = lib.mkIf config.my.desktop.terminal.kitty.enable {
    my.homebrew.casks = [ "kitty" ];
  };
}
