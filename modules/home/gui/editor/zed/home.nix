{ config, lib, ... }:
let
  cfg = config.my.gui.editor.zed;
in
{
  imports = [
    ../../../../options/gui/editor.nix
    ../../../../options/homebrew.nix
  ];

  config = lib.mkIf cfg.enable {
    my.homebrew.casks = [ "zed" ];

    xdg.configFile."zed/keymap.json".source = ../../../../../resources/zed/keymap.json;
  };
}
