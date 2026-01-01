{ config, lib, pkgs-unstable, ... }:

let
  cfg = config.modules.opencode;
in {
  options.modules.opencode.enable = lib.mkEnableOption "OpenCode Configuration";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs-unstable; [
      opencode
    ];
    xdg.configFile."opencode/config.jsonc".source = ./config/config.jsonc;
  };
}
