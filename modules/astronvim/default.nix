{ config, lib, ... }:

let
  cfg = config.modules.astronvim;
in {
  options.modules.astronvim.enable = lib.mkEnableOption "AstroNvim configuration";

  config = lib.mkIf cfg.enable {
    xdg.configFile."nvim".source = ./config;
  };
}
