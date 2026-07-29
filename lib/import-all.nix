{ lib }:
dir:
let
  entries = builtins.readDir dir;
  names = builtins.sort builtins.lessThan (builtins.filter (name:
    entries.${name} == "regular"
    && lib.hasSuffix ".nix" name
    && name != "default.nix"
  ) (builtins.attrNames entries));
in map (name: dir + "/${name}") names
