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
      "charmbracelet/tap"
      # "xenodium/macosrec"
      # "sho0pi/tap"
    ];
    brews = [
      "mas"
      "terminal-notifier"
      "bendews/tap/apw"
      # "charmbracelet/tap/crush" # 用 NUR
      "daipeihust/tap/im-select" # 输入法切换
      "shivammathur/php/php@7.2" # 开发需要的老版本
      # "yqrashawn/goku/goku" # 切换到nixpkgs
      # "xenodium/macosrec/macosrec" # 用不上
      # "sho0pi/tap/tickli" # 用不上
    ];
    casks = [
      "mos"
      "aerospace"
      "jordanbaird-ice"
      "raycast"
      "dbeaver-community"
      "karabiner-elements"
      "ghostty"
      "kitty"
      "lookaway"
      "picgo"
      "postman"
      "google-chrome"
      "the-unarchiver"
      "zerotier-one"

      "font-jetbrains-mono-nerd-font"

      # "vlc"

      # "syncthing-app"
      # "localsend"
      # "ticktick"
      # "bitwarden"
      # "betterdisplay"
      # "clash-verge-rev"
      # "zed"
      # "zen" 
      # "obsidian"
      # "chatgpt"
      # "figma"
      # "wechat"
      # "wechatwork"
      # "neteasemusic"
    ];
    masApps = {
      "Adblock Plus" = 1432731683;
      "Affinity Designer 2" = 1616831348;
      "Bob" = 1630034110;
      "Cleaner One Pro" = 1133028347;
      "RunCat" = 1429033973;
      "Tampermonkey" = 6738342400;
      "Userscripts-Mac-App" = 1463298887;
      "Xnip" = 1221250572;
      "Pages" = 409201541;
      # "Keynote" = 409183694;
      # "Numbers" = 409203825;
      # "Xcode" = 497799835;
      # "Tampermonkey Classic" = 1482490089;
      # "Orbit" = 1501298198; # 用不上
    };
  };
}
