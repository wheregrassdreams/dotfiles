{ config, lib, pkgs, ... }:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  terminfo = pkgs.runCommand "dotfiles-terminfo" { } ''
    source="$(find ${pkgs.ncurses}/share/terminfo -type f -name tmux-256color -print -quit)"
    test -n "$source"
    destination="$out/''${source#${pkgs.ncurses}/share/terminfo/}"
    mkdir -p "$(dirname "$destination")"
    cp "$source" "$destination"
  '';
  target = "${config.home.homeDirectory}/.terminfo";
  copyFile = "${pkgs.coreutils}/bin/cp";
  moveFile = "${pkgs.coreutils}/bin/mv";
  changeMode = "${pkgs.coreutils}/bin/chmod";
in
{
  # On Darwin Ghostty and Kitty are Homebrew casks. Their terminfo must be
  # copied only after brew-sync has installed the applications.
  home.activation.installTerminfo = lib.hm.dag.entryAfter (
    if isDarwin then [ "brewBundle" ] else [ "linkGeneration" ]
  ) ''
    mkdir -p ${lib.escapeShellArg target}
    copy_directory() {
      directory="$1"

      while IFS= read -r -d "" source; do
        relative="''${source#"$directory"/}"
        destination="${target}/$relative"

        if [ -e "$destination" ] && [ "$source" -ef "$destination" ]; then
          continue
        fi

        destination_directory="$(dirname "$destination")"
        mkdir -p "$destination_directory"
        ${changeMode} u+w "$destination_directory"
        temporary="$(mktemp "''${destination}.XXXXXX")"
        ${copyFile} "$source" "$temporary"
        ${moveFile} -f "$temporary" "$destination"
      done < <(find "$directory" -type f -print0)
    }

    copy_directory ${terminfo}
    ${lib.optionalString isDarwin ''
      for directory in \
        /Applications/Ghostty.app/Contents/Resources/terminfo \
        /Applications/kitty.app/Contents/Resources/terminfo; do
        if [ ! -d "$directory" ]; then
          echo "missing terminal description directory: $directory" >&2
          exit 1
        fi
        copy_directory "$directory"
      done
    ''}
  '';
}
