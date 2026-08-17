{ lib, ... }:
{
  options.my.connectivity.clashVerge = {
    enable = lib.mkEnableOption "Clash Verge Rev connectivity client";

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Tailscale hostname used by the Clash Verge Script profile";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "./tailscale";
      description = "State directory for the embedded Tailscale node";
    };

    tailnetDomain = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Tailnet DNS domain routed through the Clash policy group";
    };

    tailnetCidr = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Tailnet CIDR routed through the Clash policy group";
    };

    dnsUpstream = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "DNS upstream for the Tailnet domain";
    };
  };
}
