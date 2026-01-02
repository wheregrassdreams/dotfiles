{ config, lib, ... }:

let
  cfg = config.modules.nvim;
in {
  options.modules.nvim.enable = lib.mkEnableOption "Neovim configuration";

  config = lib.mkIf cfg.enable {
    xdg.configFile."nvim".source = ./nvim;
  };
}
