{ lib, ... }:
{
  options.my.desktop.terminal = {
    ghostty.enable = lib.mkEnableOption "Ghostty";
    kitty.enable = lib.mkEnableOption "Kitty";
  };
}
