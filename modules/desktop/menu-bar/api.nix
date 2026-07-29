{ lib, ... }:
{
  options.dotfiles.desktop.menuBar.ice.enable = lib.mkEnableOption "Ice";
}
