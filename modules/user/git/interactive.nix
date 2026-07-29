{ config, lib, ... }:
{
  options.dotfiles.git.interactive.enable = lib.mkEnableOption "interactive Git tooling";

  config = lib.mkIf (config.dotfiles.git.enable && config.dotfiles.git.interactive.enable) {
    programs.lazygit.enable = true;
  };
}
