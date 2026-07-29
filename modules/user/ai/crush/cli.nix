{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.dotfiles.ai.enable && config.dotfiles.ai.crush.cli) {
    home.packages = [ pkgs.nur.repos.charmbracelet.crush ];
  };
}
