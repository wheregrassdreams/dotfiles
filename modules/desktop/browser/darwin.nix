{ config, lib, ... }:
let
  cfg = config.dotfiles.desktop.browser;
in
{
  imports = [ ./default.nix ];

  config = {
    homebrew.brews = [ "defaultbrowser" ];
    homebrew.casks = lib.optionals cfg.chrome.enable [ "google-chrome" ]
      ++ lib.optionals cfg.zen.enable [ "zen" ];
  };
}
