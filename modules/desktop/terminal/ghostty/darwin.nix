{ config, lib, ... }:
let cfg = config.dotfiles.desktop.terminal.ghostty;
in {
  imports = [ ../default.nix ];
  config = lib.mkIf cfg.enable { homebrew.casks = [ "ghostty" ]; };
}
