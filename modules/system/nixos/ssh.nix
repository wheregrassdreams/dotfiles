{ config, lib, ... }:
let
  cfg = config.my.ssh.server;
in
{
  imports = [ ../../options/ssh.nix ];

  config = lib.mkIf cfg.enable {
    services.openssh.enable = true;
    users.users = lib.mapAttrs (_: keys: {
      openssh.authorizedKeys.keys = keys;
    }) cfg.authorizedKeys;
  };
}
