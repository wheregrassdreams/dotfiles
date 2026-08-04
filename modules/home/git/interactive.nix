{ config, lib, ... }:
{
  config = lib.mkIf (config.my.git.enable && config.my.git.interactive.enable) {
    programs.lazygit.enable = true;
  };
}
