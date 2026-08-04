{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.my.ai.enable && config.my.ai.opencode.cli.enable) {
    programs.opencode = {
      enable = true;
      package = pkgs.llm-agents.opencode.overrideAttrs (_: {
        doInstallCheck = false;
      });
    };
  };
}
