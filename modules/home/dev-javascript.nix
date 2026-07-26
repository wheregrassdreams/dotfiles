{ config, lib, inputs, system, pkgs, ... }:
let
  cfg = config.features.dev-javascript;
  pkgs-unstable = import inputs.nixpkgs-unstable { inherit system; config.allowUnfree = true; };
in {
  options.features.dev-javascript.enable = lib.mkEnableOption "JavaScript development tools";
  config = lib.mkIf cfg.enable {
    programs.bun = { enable = true; enableGitIntegration = true; package = pkgs-unstable.bun; };
    home.packages = [ pkgs.nodejs pkgs.pnpm ];
    home.sessionVariables.NODE_COMPILE_CACHE = "${config.xdg.cacheHome}/nodejs-compile-cache";
  };
}
