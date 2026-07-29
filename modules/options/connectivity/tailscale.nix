{ lib, ... }:
{
  options.dotfiles.connectivity.tailscale = {
    enable = lib.mkEnableOption "Tailscale connectivity";
    host = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Tailnet MagicDNS host for this machine";
    };
  };
}
