{ lib, ... }:
{
  options.my.desktop.workspace.enable = lib.mkEnableOption "macOS workspace applications";
}
