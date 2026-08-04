{ config, lib, pkgs, ... }:
let cfg = config.my.gui.keymap.karabiner;
in {
  imports = [
    ../../../../options/gui/keymap.nix
    ../../../../options/homebrew.nix
  ];
  config = lib.mkIf cfg.enable {
    my.homebrew = {
      taps = [{ name = "daipeihust/tap"; trusted = true; }];
      brews = [ "daipeihust/tap/im-select" ];
      casks = [ "karabiner-elements" ];
    };
    home.packages = [ pkgs.goku ];
    xdg.configFile."karabiner.edn" = {
      source = ./config/karabiner.edn;
      onChange = "${pkgs.goku}/bin/goku";
    };
  };
}
