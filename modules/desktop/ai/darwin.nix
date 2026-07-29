{ config, lib, ... }:
let
  cfg = config.dotfiles.ai;
in {
  imports = [ ../../options/ai.nix ];

  config = lib.mkIf cfg.enable {
    homebrew.casks =
      lib.optionals cfg.claude.desktop [ "claude" ]
      ++ lib.optionals cfg.opencode.desktop [ "opencode-desktop" ];
  };
}
