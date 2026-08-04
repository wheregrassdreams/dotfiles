{ lib, ... }:
{
  options.my.ssh.enable = lib.mkEnableOption "SSH defaults";
}
