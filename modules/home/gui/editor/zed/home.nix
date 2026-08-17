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

    # Zed settings are declarative. Make changes in resources/zed instead of
    # editing the generated files under ~/.config/zed.
    xdg.configFile = {
      "zed/settings.json".source = ../../../../../resources/zed/settings.json;
      "zed/keymap.json".source = ../../../../../resources/zed/keymap.json;
    };
  };
}
