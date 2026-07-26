{ config, lib, pkgs, ... }:
let cfg = config.features.base-cli;
in {
  options.features.base-cli.enable = lib.mkEnableOption "Base command-line tools";
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      act coreutils gnugrep gnumake gnused gnutar
      curl wget p7zip unrar unzip rsync lsof
      entr file findutils fontconfig grex mosh clipboard-jh
      libqalculate dust moor procs tokei tldr just sttr trash-cli tree
      sshpass tailscale xh yq quicktype
      nur.repos.charmbracelet.crush nur.repos.charmbracelet.gum
      nur.repos.charmbracelet.mods
    ] ++ lib.optionals pkgs.stdenv.isDarwin [ pngpaste ];
  };
}
