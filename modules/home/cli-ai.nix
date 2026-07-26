{ config, lib, pkgs, inputs, system, ... }:
let
  cfg = config.features.ai-cli;
  pkgs-unstable = import inputs.nixpkgs-unstable { inherit system; config.allowUnfree = true; };
in {
  options.features.ai-cli.enable = lib.mkEnableOption "AI command-line tools";
  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      package = pkgs.llm-agents.opencode.overrideAttrs (_: { doInstallCheck = false; });
    };
    programs.codex = { enable = true; package = pkgs-unstable.codex; };
    programs.claude-code = { enable = false; package = pkgs.llm-agents.claude-code; };
  };
}
