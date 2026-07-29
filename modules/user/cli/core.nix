{ pkgs, ... }: {
  home.packages = with pkgs; [
    coreutils gnugrep gnumake gnused gnutar
    curl wget p7zip unrar unzip rsync lsof
    file findutils tree
  ];
}
