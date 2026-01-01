{ config, lib, ... }:

let
  cfg = config.modules.cli.tools;
in {
  options.modules.cli.tools.enable = lib.mkEnableOption "Small CLI tool bundle";

  config = lib.mkIf cfg.enable {
    modules = {
      aichat.enable = true;
      btop.enable = true;
      eza.enable = true;
      fd.enable = true;
      lazygit.enable = true;
      opencode.enable = true;
      starship.enable = true;
      tmux.enable = true;
    };
  };
}
