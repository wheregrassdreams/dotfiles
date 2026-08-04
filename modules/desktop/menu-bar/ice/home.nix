{ config, lib, ... }: {
  imports = [
    ../default.nix
    ../../../options/homebrew.nix
  ];

  config = lib.mkIf config.dotfiles.desktop.menuBar.ice.enable {
    dotfiles.homebrew.casks = [ "jordanbaird-ice" ];
  };
}
