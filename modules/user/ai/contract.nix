{ lib }:
{
  namespace = "dotfiles.ai";
  description = "AI agent environment";

  agents = {
    codex.surfaces.cli = {
      description = "Codex command-line agent";
      module = ./codex/cli.nix;
    };

    claude.surfaces = {
      cli = {
        description = "Claude Code command-line agent";
        module = ./claude/cli.nix;
      };
      desktop.description = "Claude desktop app";
    };

    opencode.surfaces = {
      cli = {
        description = "OpenCode command-line agent";
        module = ./opencode/cli.nix;
      };
      desktop.description = "OpenCode desktop app";
    };

    crush.surfaces.cli = {
      description = "Crush command-line agent";
      module = ./crush/cli.nix;
    };
  };
}
