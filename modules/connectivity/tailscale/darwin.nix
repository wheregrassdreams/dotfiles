{ config, lib, ... }:
let cfg = config.dotfiles.connectivity.tailscale;
in {
  imports = [ ../../options/connectivity/tailscale.nix ];
  config = lib.mkIf cfg.enable { homebrew.casks = [ "tailscale" ]; };
}
