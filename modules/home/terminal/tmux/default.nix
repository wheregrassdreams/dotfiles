{ lib, ... }@args:
let
  fragments = [
    ./core.nix
    ./bindings.nix
    ./copy-mode.nix
    ./finder.nix
    ./input-method.nix
    ./status.nix
  ];
  evaluate = path:
    let
      module = import path;
      result = if builtins.isFunction module then module args else module;
    in
      result.config or result;
in
{
  config = lib.mkMerge (map evaluate fragments);
}
