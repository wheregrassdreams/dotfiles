{ config, lib, ... }:
let cfg = config.dotfiles.desktop.menuBar.ice;
in {
  imports = [ ../default.nix ];
  config = lib.mkIf cfg.enable { homebrew.casks = [ "jordanbaird-ice" ]; };
}
