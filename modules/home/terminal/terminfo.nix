{ config, lib, pkgs, ... }:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  terminfoDirectories =
    [ "${pkgs.ncurses}/share/terminfo" ]
    ++ lib.optionals (!isDarwin) [
      "${pkgs.kitty.terminfo}/share/terminfo"
      "${pkgs.ghostty.terminfo}/share/terminfo"
    ];
  terminfo = pkgs.runCommand "dotfiles-terminfo" { } ''
    mkdir -p "$out"

    for directory in ${lib.concatStringsSep " " terminfoDirectories}; do
      if [ -d "$directory" ]; then
        cp -R "$directory"/. "$out"/
      fi
    done
  '';
  target = "${config.home.homeDirectory}/.terminfo";
  copy = "${pkgs.coreutils}/bin/cp -R";
in
{
  # On Darwin Ghostty and Kitty are Homebrew casks. Their terminfo must be
  # copied only after brew-sync has installed the applications.
  home.activation.installTerminfo = lib.hm.dag.entryAfter (
    if isDarwin then [ "brewBundle" ] else [ "linkGeneration" ]
  ) ''
    mkdir -p ${lib.escapeShellArg target}
    ${copy} ${terminfo}/. ${lib.escapeShellArg target}/
    ${lib.optionalString isDarwin ''
      for directory in \
        /Applications/Ghostty.app/Contents/Resources/terminfo \
        /Applications/kitty.app/Contents/Resources/terminfo; do
        if [ ! -d "$directory" ]; then
          echo "missing terminal description directory: $directory" >&2
          exit 1
        fi
        ${copy} "$directory"/. ${lib.escapeShellArg target}/
      done
    ''}
  '';
}
