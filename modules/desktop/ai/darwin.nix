{ config, lib, ... }:
let
  cfg = config.dotfiles.ai;
in {
  imports = [ ./default.nix ];

  config = lib.mkIf cfg.enable {
    homebrew.casks =
      lib.optionals cfg.claude.desktop [ "claude" ]
      ++ lib.optionals cfg.opencode.desktop [ "opencode-desktop" ];
  };
}
