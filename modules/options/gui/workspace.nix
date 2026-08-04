{ lib, ... }:
{
  options.my.gui.workspace.enable = lib.mkEnableOption "macOS workspace applications";
}
