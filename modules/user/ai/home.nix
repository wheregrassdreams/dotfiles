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

  options.my.ai.dataHome = lib.mkOption {
    type = lib.types.str;
    default = "${config.my.paths.xdg.data}/agent";
    description = "shared data directory for AI agent resources";
  };

  config = lib.mkIf cfg.enable {
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
