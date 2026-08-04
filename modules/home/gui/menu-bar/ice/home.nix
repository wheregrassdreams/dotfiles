{ config, lib, ... }: {
  imports = [
    ../default.nix
    ../../../../options/homebrew.nix
  ];

  config = lib.mkIf config.my.desktop.menuBar.ice.enable {
    my.homebrew.casks = [ "jordanbaird-ice" ];
  };
}
