{ inputs, system, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  programs.codex = {
    enable = true;
    package = pkgs-unstable.codex;
  };
}
