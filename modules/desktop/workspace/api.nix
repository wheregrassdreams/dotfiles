{ lib, ... }:
{
  options.dotfiles.desktop.workspace.enable = lib.mkEnableOption "macOS workspace applications";
}
