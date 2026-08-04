{ config, lib, pkgs, ... }:
{
  options.my.git.gitea.enable = lib.mkEnableOption "Gitea CLI";

  config = lib.mkIf (config.my.git.enable && config.my.git.gitea.enable) {
    home.packages = [ pkgs.tea ];
  };
}
