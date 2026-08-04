{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.my.ai.enable && config.my.ai.crush.cli) {
    home.packages = [ pkgs.nur.repos.charmbracelet.crush ];
  };
}
