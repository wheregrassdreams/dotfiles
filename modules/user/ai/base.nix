{ config, lib, ... }:
let
  cfg = config.dotfiles.ai;
in {
  home.sessionVariables = {
    AI_AGENT_HOME = cfg.dataHome;
    AI_AGENT_SKILLS_DIR = "${cfg.dataHome}/skills";
    AI_AGENT_MCP_DIR = "${cfg.dataHome}/mcp";
  };

  home.activation.createAgentDataDirectories = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p ${lib.escapeShellArg cfg.dataHome}/skills ${lib.escapeShellArg cfg.dataHome}/mcp
  '';
}
