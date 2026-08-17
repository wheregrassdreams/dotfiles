{ lib, ... }:
{
  options.my.gui.editor = {
    zed.enable = lib.mkEnableOption "Zed editor";
  };
}
