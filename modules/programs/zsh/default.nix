{ config, lib, ... }:

let
  cfg = config.modules.zsh;
in {
  options.modules.zsh.enable = lib.mkEnableOption "zsh configuration";

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = false;
    home.file.".zshrc".source = ./config/zshrc.zen;
  };
}
