{ ... }:
{
  # Static Home Manager-side desktop registry.
  imports = [
    ./file-browser-home.nix
    ./browser/home.nix
    ./terminal/default.nix
    ./terminal/ghostty/home.nix
    ./keymap/default.nix
    ./keymap/karabiner/home.nix
    ./network/default.nix
    ./network/tailscale/home.nix
    ./menu-bar/default.nix
    ./workspace/default.nix
  ];
}
