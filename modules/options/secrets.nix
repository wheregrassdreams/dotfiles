{ lib, ... }:
{
  options.my.secrets.enable = lib.mkEnableOption "SOPS tooling";
}
