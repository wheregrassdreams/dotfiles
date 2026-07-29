{ config, lib, pkgs, ... }:
let cfg = config.dotfiles.desktop.keymap.karabiner;
in {
  imports = [ ../default.nix ];
  config = lib.mkIf cfg.enable {
  home.packages = [ pkgs.goku ];
  xdg.configFile."karabiner.edn" = {
    source = ./config/karabiner.edn;
    onChange = "${pkgs.goku}/bin/goku";
  };
  };
}
