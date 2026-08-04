{ config, lib, ... }:
let
  cfg = config.my.ai;
in {
  imports = [
    ./codex/cli.nix
    ./claude/cli.nix
    ./crush/cli.nix
    ./opencode/cli.nix
  ];

  config = lib.mkIf cfg.enable {
    my.ai.dataHome = lib.mkDefault "${config.my.paths.xdg.data}/agent";
    home.sessionVariables = {
      AI_AGENT_HOME = cfg.dataHome;
      AI_AGENT_SKILLS_DIR = "${cfg.dataHome}/skills";
      AI_AGENT_MCP_DIR = "${cfg.dataHome}/mcp";
    };

    home.activation.createAgentDataDirectories = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p ${lib.escapeShellArg cfg.dataHome}/skills ${lib.escapeShellArg cfg.dataHome}/mcp
    '';
  };
}
