{ lib, ... }:
{
  options.dotfiles.terminal.tmux = {
    enable = lib.mkEnableOption "tmux";
    inputMethod.command = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };
}
