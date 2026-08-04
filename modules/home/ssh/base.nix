{ config, lib, ... }:
{
  config = lib.mkIf config.my.ssh.enable {
    programs.ssh = {
      enable = true;
      matchBlocks."*" = {
        setEnv.TERM = "xterm-256color";
        serverAliveInterval = 30;
        serverAliveCountMax = 3;
      };
    };
  };
}
