{ pkgs, ... }: {
  home.packages = with pkgs; [ alejandra deadnix nil nixd nixfmt-rfc-style nixpkgs-fmt statix ];
}
