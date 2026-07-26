{ config, lib, pkgs, ... }:
let cfg = config.features.dev-nix;
in {
  options.features.dev-nix.enable = lib.mkEnableOption "Nix development tools";
  config = lib.mkIf cfg.enable { home.packages = with pkgs; [ alejandra deadnix nil nixd nixfmt-rfc-style nixpkgs-fmt statix ]; };
}
