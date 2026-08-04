{ config, lib, pkgs, ... }:
{
  options.my.git.gitlab.enable = lib.mkEnableOption "GitLab CLI";

  config = lib.mkIf (config.my.git.enable && config.my.git.gitlab.enable) {
    home.packages = [ pkgs.glab ];
  };
}
