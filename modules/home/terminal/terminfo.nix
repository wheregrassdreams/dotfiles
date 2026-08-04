{ pkgs, ... }:
let
  terminfo = pkgs.runCommand "dotfiles-terminfo" { } ''
    mkdir -p "$out"

    for directory in \
      ${pkgs.ncurses}/share/terminfo \
      ${pkgs.tmux}/share/terminfo \
      ${pkgs.kitty}/share/terminfo \
      ${pkgs.ghostty}/share/terminfo; do
      if [ -d "$directory" ]; then
        cp -R "$directory"/. "$out"/
      fi
    done
  '';
in
{
  # Keep only terminal descriptions in the user profile. The source packages
  # are build inputs, not runtime references of the deployed directory.
  home.file.".terminfo".source = terminfo;
}
