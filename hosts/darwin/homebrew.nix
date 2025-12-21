{ config, userName, homebrew-core, homebrew-cask, ... }: {
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    autoMigrate = true;
    user = userName;
    mutableTaps = true;
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };
  };
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    global.brewfile = false;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    taps = builtins.attrNames config.nix-homebrew.taps ++ [
      "bendews/tap"
      "daipeihust/tap"
      "oven-sh/bun"
      "shivammathur/php"
      "xenodium/macosrec"
      "charmbracelet/tap"
    ];
    brews = [
      "mas"
      "bendews/tap/apw"
      "charmbracelet/tap/crush"
      "daipeihust/tap/im-select"
      "oven-sh/bun/bun"
      "shivammathur/php/php@7.2"
      "xenodium/macosrec/macosrec"
    ];
    casks = [
      "aerospace"
      "airbattery"
      # "bartender"
      "bitwarden"
      "cheatsheet"
      "claude-code"
      "font-fira-code"
      "font-jetbrains-mono-nerd-font"
      "ghostty"
      "kitty"
      "lookaway"
      "openinterminal"
      "picgo"
      "postman"
      "the-unarchiver"
      "zerotier-one"
    ];
    masApps = {
      "Adblock Plus" = 1432731683;
      "AdGuard for Safari" = 1440147259;
      "Affinity Designer 2" = 1616831348;
      "Bob" = 1630034110;
      "Cleaner One Pro" = 1133028347;
      # "Keynote 讲演" = 409183694;
      # "Numbers 表格" = 409203825;
      "Orbit" = 1501298198;
      "Pages 文稿" = 409201541;
      "RunCat" = 1429033973;
      "Tampermonkey" = 6738342400;
      "Tampermonkey Classic" = 1482490089;
      "Userscripts-Mac-App" = 1463298887;
      "Vimari" = 1480933944;
      # "Xcode" = 497799835;
      "Xnip" = 1221250572;
      # "库乐队" = 682658836;
    };
  };
}
