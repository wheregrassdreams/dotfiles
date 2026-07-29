{ config, lib, pkgs, ... }:
let
  cfg = config.dotfiles.desktop.network.tailscale;
  host = cfg.host;
in {
  imports = [ ../default.nix ];
  config = lib.mkIf cfg.enable {
  home.file.".local/bin/tailscale-self-dns" = {
    executable = true;
    text = ''
      actual="$(${pkgs.tailscale}/bin/tailscale status --json | ${pkgs.jq}/bin/jq -r '.Self.DNSName')"
      test -n "$actual" -a "$actual" != "null" || { echo 'Tailscale daemon unavailable' >&2; exit 1; }
      echo "$actual"
      test "$actual" = '${host}' || { echo "declared host: ${host}" >&2; exit 2; }
    '';
  };
  };
}
