{ lib, ... }:
{
  options.dotfiles.desktop.fileBrowser.baseline.enable = lib.mkEnableOption "file browser working baseline";
}
