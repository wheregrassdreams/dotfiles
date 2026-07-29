{ config, lib, ... }:
{
  imports = [ ../default.nix ];

  config = lib.mkIf config.dotfiles.desktop.terminal.kitty.enable {
    homebrew.casks = [ "kitty" ];
  };
}
