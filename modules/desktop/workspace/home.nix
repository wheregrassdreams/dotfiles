{ config, lib, ... }:
{
  imports = [
    ./default.nix
    ../../options/homebrew.nix
  ];

  config = lib.mkIf config.dotfiles.desktop.workspace.enable {
    dotfiles.homebrew = {
      taps = [
        { name = "bendews/tap"; trusted = true; }
        { name = "shivammathur/php"; trusted = true; }
      ];
      brews = [
        "mas"
        "terminal-notifier"
        "bendews/tap/apw"
        "shivammathur/php/php@7.2"
      ];
      casks = [
        "mos"
        "aerospace"
        "raycast"
        "dbeaver-community"
        "lookaway"
        "picgo"
        "postman"
        "the-unarchiver"
        "font-jetbrains-mono-nerd-font"
      ];
    };
  };
}
