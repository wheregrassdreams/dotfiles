{ config, lib, pkgs, ... }:
{
  options.dotfiles.git.gitea.enable = lib.mkEnableOption "Gitea CLI";

  config = lib.mkIf (config.dotfiles.git.enable && config.dotfiles.git.gitea.enable) {
    home.packages = [ pkgs.tea ];
  };
}
