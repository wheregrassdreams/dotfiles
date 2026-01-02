{ nixpkgs }:

let
  hostCmd =
    nixpkgs.legacyPackages."aarch64-darwin".runCommand
      "darwin-hostname"
      { }
      ''
        /usr/sbin/scutil --get LocalHostName | tr -d '\n' > $out
      '';
in
builtins.readFile hostCmd
