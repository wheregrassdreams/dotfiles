{ lib, ... }:
{
  options.dotfiles.desktop.network.tailscale = {
    enable = lib.mkEnableOption "Tailscale app";
    host = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Tailnet MagicDNS host";
    };
  };
}
