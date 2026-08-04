{ config, lib, pkgs, ... }:
let
  cfg = config.my.desktop.browser;
  setDefaultBrowser = pkgs.writeShellScriptBin "browser-default" ''
    defaultbrowser=${lib.escapeShellArg "${config.my.homebrew.brewPrefix}/bin/defaultbrowser"}
    if [ ! -x "$defaultbrowser" ]; then
      echo "defaultbrowser is unavailable; run brew-sync before setting the default browser." >&2
      exit 0
    fi

    exec "$defaultbrowser" ${cfg.default}
  '';
in {
  imports = [
    ./default.nix
    ../../../options/homebrew.nix
  ];

  config = {
    my.homebrew = {
      brews = [ "defaultbrowser" ];
      casks = lib.optionals cfg.chrome.enable [ "google-chrome" ]
        ++ lib.optionals cfg.zen.enable [ "zen" ];
    };

    home.packages = [ setDefaultBrowser ];
    home.activation.setDefaultBrowser = lib.hm.dag.entryAfter [ "brewBundle" ] ''
      ${setDefaultBrowser}/bin/browser-default
    '';
  };
}
