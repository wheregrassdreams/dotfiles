{ ... }:
{
  # Static Home Manager-side desktop registry.
  imports = [
    ./file-browser-home.nix
    ./browser/home.nix
    ./ai/homebrew.nix
    ./terminal/default.nix
    ./terminal/ghostty/home.nix
    ./terminal/kitty/homebrew.nix
    ./keymap/default.nix
    ./keymap/karabiner/home.nix
    ./menu-bar/default.nix
    ./menu-bar/ice/home.nix
    ./workspace/default.nix
    ./workspace/home.nix
  ];
}
