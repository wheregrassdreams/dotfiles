{ config, lib, pkgs, ... }:
let cfg = config.dotfiles; in
{
  options.dotfiles.git.github.enable = lib.mkEnableOption "GitHub CLI";

  config = lib.mkIf (cfg.git.enable && cfg.git.github.enable) {
    home.packages = [ pkgs.gh ];
    programs.ssh.matchBlocks."github.com" = {
      hostname = "ssh.github.com";
      port = 443;
      user = "git";
    };
  };
}
