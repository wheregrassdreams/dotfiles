{ config, lib, pkgs, ... }:
{
  config = lib.mkIf (config.dotfiles.ai.enable && config.dotfiles.ai.claude.cli.enable) {
    programs.claude-code = {
      enable = true;
      package = pkgs.llm-agents.claude-code;
    };
  };
}
