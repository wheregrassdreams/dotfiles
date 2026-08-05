{ pkgs, ... }: {
  home.packages = with pkgs; [
    gnumake just
    curl wget p7zip unrar unzip rsync lsof
  ];
}
