{ config, lib, ... }:

let
  cfg = config.modules.aerospace;
in {
  options.modules.aerospace.enable = lib.mkEnableOption "AeroSpace configuration";

  config = lib.mkIf cfg.enable {
    home.file.".aerospace.toml".source = ./config/aerospace.toml;
  };
}
