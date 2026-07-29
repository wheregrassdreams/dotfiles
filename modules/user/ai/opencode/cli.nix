{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.dotfiles.ai.enable && config.dotfiles.ai.opencode.cli.enable) {
    programs.opencode = {
      enable = true;
      package = pkgs.llm-agents.opencode.overrideAttrs (_: {
        doInstallCheck = false;
      });
    };
  };
}
