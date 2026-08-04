{ lib, ... }:
{
  options.my.ai = {
    enable = lib.mkEnableOption "AI agent environment";
    dataHome = lib.mkOption {
      type = lib.types.str;
      description = "Shared data directory for AI agent resources";
    };

    codex.cli = lib.mkEnableOption "Codex command-line agent";

    claude = {
      cli.enable = lib.mkEnableOption "Claude Code command-line agent";
      desktop.enable = lib.mkEnableOption "Claude desktop app";
    };

    opencode = {
      cli.enable = lib.mkEnableOption "OpenCode command-line agent";
      desktop.enable = lib.mkEnableOption "OpenCode desktop app";
    };

    crush.cli = lib.mkEnableOption "Crush command-line agent";
  };
}
