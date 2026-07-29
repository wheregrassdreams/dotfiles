{ pkgs, ... }: {
  home.packages = with pkgs; [
    hurl
    sshpass
    act
    xh
    entr
    just
    sttr
    tldr
    trash-cli
    clipboard-jh
    nur.repos.charmbracelet.gum
    nur.repos.charmbracelet.mods
  ];
}
