{ config, lib, ... }:

let
  cfg = config.modules.yazi;
in {
  options.modules.yazi.enable = lib.mkEnableOption "Yazi configuration";

  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";
    };
    xdg.configFile."yazi".source = ./config;
  };
}
