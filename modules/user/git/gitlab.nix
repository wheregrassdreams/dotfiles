{ config, lib, pkgs, ... }:
{
  options.dotfiles.git.gitlab.enable = lib.mkEnableOption "GitLab CLI";

  config = lib.mkIf (config.dotfiles.git.enable && config.dotfiles.git.gitlab.enable) {
    home.packages = [ pkgs.glab ];
  };
}
