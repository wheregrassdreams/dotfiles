{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.my.git.enable && config.my.git.gitlab.enable) {
    home.packages = [ pkgs.glab ];
  };
}
