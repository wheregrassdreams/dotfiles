{ config, lib, inputs, system, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  config = lib.mkIf (config.dotfiles.ai.enable && config.dotfiles.ai.codex.cli) {
    programs.codex = {
      enable = true;
      package = pkgs-unstable.codex;
    };
  };
}
