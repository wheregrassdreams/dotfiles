{ config, lib, ... }:
{
  imports = [ ./file-browser.nix ];

  config = lib.mkIf config.my.desktop.fileBrowser.baseline.enable {
    targets.darwin.defaults."com.apple.finder" = {
      _FXShowPosixPathInTitle = true;
      _FXSortFoldersFirst = true;
      _FXSortFoldersFirstOnDesktop = true;
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      ShowPathBar = true;
      ShowStatusBar = true;
    };
  };
}
