{ config, lib, ... }:

let
  cfg = config.modules.vscode;
in {
  options.modules.vscode.enable = lib.mkEnableOption "VSCode configuration";

  config = lib.mkIf cfg.enable {
    xdg.configFile."vscode".source = ./config;
  };
}
