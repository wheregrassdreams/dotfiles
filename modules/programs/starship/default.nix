{ config, lib, ... }:

let
  cfg = config.modules.starship;
in {
  options.modules.starship.enable = lib.mkEnableOption "Starship configuration";

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = false;
    };
    xdg.configFile."starship.toml".source = ./config/starship.toml;
  };
}
