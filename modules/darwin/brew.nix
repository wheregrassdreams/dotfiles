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
      "terminal-notifier"
      "bendews/tap/apw"
      # "sho0pi/tap/tickli" # 用不上
      "charmbracelet/tap/crush"
      "daipeihust/tap/im-select" # 输入法切换
      "shivammathur/php/php@7.2" # 开发需要的老版本
      # "xenodium/macosrec/macosrec" # 用不上
      "yqrashawn/goku/goku"
    ];
    casks = [
      "mos"
      "aerospace"
      "jordanbaird-ice"
      "raycast"
      "dbeaver-community"
      "karabiner-elements"
      "codex"
      "claude-code"
      # "font-fira-code" # 暂时不需要
      "font-jetbrains-mono-nerd-font"
      "ghostty"
      "kitty"
      "lookaway"
      "picgo"
      "postman"
      "google-chrome"
      "the-unarchiver"
      "zerotier-one"

      # "localsend"
      # "ticktick"
      # "bitwarden"
      # "betterdisplay"
      # "clash-verge-rev"
      # "zed"
      # "zen" "obsidian"
      # "chatgpt"
      # "figma"
      # "wechat"
      # "wechatwork"
      # "neteasemusic"
    ];
    masApps = {
      "Adblock Plus" = 1432731683;
      # "AdGuard for Safari" = 1440147259;
      "Affinity Designer 2" = 1616831348;
      "Bob" = 1630034110;
      "Cleaner One Pro" = 1133028347;
      "RunCat" = 1429033973;
      "Tampermonkey" = 6738342400;
      "Userscripts-Mac-App" = 1463298887;
      # "Vimari" = 1480933944;
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
