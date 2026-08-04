{ lib, ... }:
{
  options.my.gui.terminal = {
    ghostty.enable = lib.mkEnableOption "Ghostty";
    kitty.enable = lib.mkEnableOption "Kitty";
  };
}
