{ config, lib, ... }:
{
  options.my.git.interactive.enable = lib.mkEnableOption "interactive Git tooling";

  config = lib.mkIf (config.my.git.enable && config.my.git.interactive.enable) {
    programs.lazygit.enable = true;
  };
}
