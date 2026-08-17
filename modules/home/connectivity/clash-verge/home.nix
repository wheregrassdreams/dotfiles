{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.connectivity.clashVerge;
  script = pkgs.writeText "clash-verge-tailnet.js" (
    builtins.replaceStrings
      [
        "__CLASH_VERGE_HOSTNAME__"
        "__CLASH_VERGE_STATE_DIR__"
        "__CLASH_VERGE_TAILNET_DOMAIN__"
        "__CLASH_VERGE_TAILNET_CIDR__"
        "__CLASH_VERGE_DNS_UPSTREAM__"
      ]
      [
        (builtins.toJSON cfg.hostname)
        (builtins.toJSON cfg.stateDir)
        (builtins.toJSON cfg.tailnetDomain)
        (builtins.toJSON cfg.tailnetCidr)
        (builtins.toJSON cfg.dnsUpstream)
      ]
      (builtins.readFile ../../../../resources/clash-verge/clash-verge-tailnet.js)
  );
in
{
  imports = [
    ../../../options/connectivity/clash-verge.nix
    ../../../options/homebrew.nix
  ];

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !cfg.enable || cfg.hostname != "";
          message = "my.connectivity.clashVerge.hostname must be set when Clash Verge is enabled";
        }
        {
          assertion = !cfg.enable || cfg.tailnetDomain != "";
          message = "my.connectivity.clashVerge.tailnetDomain must be set when Clash Verge is enabled";
        }
        {
          assertion = !cfg.enable || cfg.tailnetCidr != "";
          message = "my.connectivity.clashVerge.tailnetCidr must be set when Clash Verge is enabled";
        }
        {
          assertion = !cfg.enable || cfg.dnsUpstream != "";
          message = "my.connectivity.clashVerge.dnsUpstream must be set when Clash Verge is enabled";
        }
      ];
    }
    (lib.mkIf cfg.enable {
      my.homebrew.casks = [ "clash-verge-rev" ];
      home.file."Library/Application Support/io.github.clash-verge-rev.clash-verge-rev/profiles/Script.js".source =
        script;
    })
  ];
}
