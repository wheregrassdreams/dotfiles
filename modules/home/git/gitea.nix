{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.my.git.enable && config.my.git.gitea.enable) {
    home.packages = [ pkgs.tea ];
  };
}
