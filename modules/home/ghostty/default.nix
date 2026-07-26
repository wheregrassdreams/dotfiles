{ config, lib, ... }:
let cfg = config.features.ghostty;
in {
  options.features.ghostty.enable = lib.mkEnableOption "Ghostty configuration";
  config = lib.mkIf cfg.enable {
  xdg.configFile."ghostty/config".source = ./config;
  xdg.configFile."ghostty/shaders".source = ./shaders;
  };
}
