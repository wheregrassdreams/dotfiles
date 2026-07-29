{ config, lib, ... }:
let cfg = config.dotfiles.desktop.keymap.karabiner;
in {
  imports = [ ../default.nix ];
  config = lib.mkIf cfg.enable {
    homebrew.taps = [ "daipeihust/tap" ];
    homebrew.brews = [ "daipeihust/tap/im-select" ];
    homebrew.casks = [ "karabiner-elements" ];
  };
}
