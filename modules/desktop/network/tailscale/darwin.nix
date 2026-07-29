{ config, lib, ... }:
let cfg = config.dotfiles.desktop.network.tailscale;
in {
  imports = [ ../default.nix ];
  config = lib.mkIf cfg.enable { homebrew.casks = [ "tailscale" ]; };
}
