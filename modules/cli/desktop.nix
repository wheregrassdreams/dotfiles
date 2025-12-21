{ config, lib, pkgs, isDarwin, ... }:

let
  cfg = config.modules.cli.desktop;
in {
  options.modules.cli.desktop.enable = lib.mkEnableOption "Desktop CLI applications";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      whois
      ffmpeg
      imagemagick
      p7zip
      chafa
      hugo
      pandoc
      presenterm
      typst
      yt-dlp
      openconnect
      testdisk
      qmk
      cmatrix
      openssl
      wireguard-tools
      nixos-anywhere
    ] ++ lib.optionals (!isDarwin) [
      sbctl
    ] ++ lib.optionals (isDarwin) [
      duti
    ];
  };
}
