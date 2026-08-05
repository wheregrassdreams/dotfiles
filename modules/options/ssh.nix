{ lib, ... }:
{
  options.my.ssh = {
    enable = lib.mkEnableOption "SSH client defaults";

    server = {
      enable = lib.mkEnableOption "an SSH server";

      authorizedKeys = lib.mkOption {
        type = lib.types.attrsOf (lib.types.listOf lib.types.str);
        default = { };
        description = ''
          Public keys grouped by local user for a future NixOS SSH server.
          Keys may be declared before the server is enabled.
        '';
      };
    };
  };
}
