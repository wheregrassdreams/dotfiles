{ lib, ... }:
{
  options.dotfiles.desktop.keymap.karabiner.enable = lib.mkEnableOption "Karabiner";
}
