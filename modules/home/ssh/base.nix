{ config, lib, ... }:
{
  config = lib.mkIf config.my.ssh.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      includes = [ "~/.ssh/config.local" ];
      matchBlocks."*" = {
        forwardAgent = false;
        hashKnownHosts = true;
        serverAliveInterval = 30;
        serverAliveCountMax = 3;
        controlMaster = "auto";
        controlPath = "~/.ssh/control-%C";
        controlPersist = "30m";
        extraOptions.StrictHostKeyChecking = "ask";
      };
    };
  };
}
