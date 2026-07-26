{ config, lib, pkgs, ... }:
let cfg = config.features.data-cli;
in {
  options.features.data-cli.enable = lib.mkEnableOption "Data and database command-line tools";
  config = lib.mkIf cfg.enable { home.packages = with pkgs; [ csvkit mycli mysql-shell ]; };
}
