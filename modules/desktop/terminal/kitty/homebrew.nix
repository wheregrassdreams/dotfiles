{ config, lib, ... }:
{
  imports = [
    ../default.nix
    ../../../options/homebrew.nix
  ];

  config = lib.mkIf config.dotfiles.desktop.terminal.kitty.enable {
    dotfiles.homebrew.casks = [ "kitty" ];
  };
}
