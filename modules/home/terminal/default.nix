{ dotfilesLib, config, lib, pkgs, isDarwin, ... }@ctx:
dotfilesLib.domain ctx {
  namespace = "my.terminal";
  description = "terminal environment";

  features.tmux = {
    description = "tmux";
    module = ./tmux/default.nix;
    settings.inputMethod.command = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };
}
