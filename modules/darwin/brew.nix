{ config, ... }: {
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
      "shivammathur/php"
      "xenodium/macosrec"
      "charmbracelet/tap"
      # "sho0pi/tap"
    ];
    brews = [
      "mas"
      "bendews/tap/apw"
      # "sho0pi/tap/tickli"
      "charmbracelet/tap/crush"
      "daipeihust/tap/im-select"
      "shivammathur/php/php@7.2"
      "xenodium/macosrec/macosrec"
      "yqrashawn/goku/goku"
    ];
    casks = [
      "mos"
      "aerospace"
      # "clash-verge-rev"
      # "zen"
      "jordanbaird-ice"
      "bitwarden"
      "raycast"
      "dbeaver-community"
      # "ticktick"
      # "cheatsheet"
      "karabiner-elements"
      "codex"
      "claude-code"
      "font-fira-code"
      "font-jetbrains-mono-nerd-font"
      "ghostty"
      "kitty"
      "lookaway"
      "picgo"
      "postman"
      "google-chrome"
      "the-unarchiver"
      "zerotier-one"
    ];
    masApps = {
      "Adblock Plus" = 1432731683;
      "AdGuard for Safari" = 1440147259;
      "Affinity Designer 2" = 1616831348;
      "Bob" = 1630034110;
      "Cleaner One Pro" = 1133028347;
      # "Keynote" = 409183694;
      # "Numbers" = 409203825;
      "Orbit" = 1501298198;
      "Pages 文稿" = 409201541;
      "RunCat" = 1429033973;
      "Tampermonkey" = 6738342400;
      "Tampermonkey Classic" = 1482490089;
      "Userscripts-Mac-App" = 1463298887;
      "Vimari" = 1480933944;
      # "Xcode" = 497799835;
      "Xnip" = 1221250572;
    };
  };
}
