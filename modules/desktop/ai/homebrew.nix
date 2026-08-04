{ config, lib, ... }:
let cfg = config.my.ai;
in {
  imports = [
    ../../options/ai.nix
    ../../options/homebrew.nix
  ];

  config = lib.mkIf cfg.enable {
    my.homebrew.casks =
      lib.optionals cfg.claude.desktop.enable [ "claude" ]
      ++ lib.optionals cfg.opencode.desktop.enable [ "opencode-desktop" ];
  };
}
