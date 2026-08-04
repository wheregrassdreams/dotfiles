{ config, lib, pkgs, ... }:
let cfg = config.dotfiles.desktop.keymap.karabiner;
in {
  imports = [
    ../default.nix
    ../../../options/homebrew.nix
  ];
  config = lib.mkIf cfg.enable {
    dotfiles.homebrew = {
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
