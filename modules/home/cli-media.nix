{ config, lib, pkgs, ... }:
let cfg = config.features.media-cli;
in {
  options.features.media-cli.enable = lib.mkEnableOption "Media command-line tools";
  config = lib.mkIf cfg.enable { home.packages = with pkgs; [ ffmpeg imagemagick resvg ]; };
}
