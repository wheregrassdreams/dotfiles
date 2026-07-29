{ config, lib, pkgs, ... }:
let
  cfg = config.dotfiles.desktop.browser;
  setDefaultBrowser = pkgs.writeShellScriptBin "browser-default" ''
    defaultbrowser=/opt/homebrew/bin/defaultbrowser
    if [ ! -x "$defaultbrowser" ]; then
      echo "defaultbrowser is unavailable; run brew-sync before setting the default browser." >&2
      exit 0
    fi

    exec "$defaultbrowser" ${cfg.default}
  '';
in {
  imports = [ ./default.nix ];

  home.packages = [ setDefaultBrowser ];
  home.activation.setDefaultBrowser = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${setDefaultBrowser}/bin/browser-default
  '';
}
