{ ... }:
{
  # Static Home Manager-side desktop registry.
  imports = [
    ../../options/gui/file-browser.nix
    ../../options/gui/browser.nix
    ../../options/gui/terminal.nix
    ../../options/gui/keymap.nix
    ../../options/gui/menu-bar.nix
    ../../options/gui/workspace.nix
    ./file-browser-home.nix
    ./browser/home.nix
    ./ai/homebrew.nix
    ./terminal/ghostty/home.nix
    ./terminal/kitty/homebrew.nix
    ./keymap/karabiner/home.nix
    ./menu-bar/ice/home.nix
    ./workspace/home.nix
  ];
}
