{ pkgs, ... }: {
  home.packages = with pkgs; [
    gnumake
    curl wget p7zip unrar unzip rsync lsof
  ];
}
