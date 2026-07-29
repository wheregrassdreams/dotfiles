{ config, lib, pkgs, ... }:
{
  options.dotfiles.git.github.enable = lib.mkEnableOption "GitHub CLI";

  config = lib.mkIf (config.dotfiles.git.enable && config.dotfiles.git.github.enable) {
    home.packages = [ pkgs.gh ];
    programs.ssh.matchBlocks."github.com" = {
      hostname = "ssh.github.com";
      port = 443;
      user = "git";
    };
  };
}
