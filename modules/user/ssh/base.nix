{ config, lib, ... }:
{
  options.dotfiles.ssh.enable = lib.mkEnableOption "SSH defaults";

  config = lib.mkIf config.dotfiles.ssh.enable {
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
