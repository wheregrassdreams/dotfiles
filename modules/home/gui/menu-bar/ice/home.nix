{ config, lib, ... }: {
  imports = [
    ../../../../options/gui/menu-bar.nix
    ../../../../options/homebrew.nix
  ];

  config = lib.mkIf config.my.gui.menuBar.ice.enable {
    my.homebrew.casks = [ "jordanbaird-ice" ];
  };
}
