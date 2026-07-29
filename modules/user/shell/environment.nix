{ dotfilesPath, ... }: {
  home.sessionVariables.DOTFILES = dotfilesPath;
  home.sessionPath = [ "$HOME/.local/bin" ];
}
