{ ... }:
{
  # Static Darwin-side desktop registry. Targets assemble this sibling domain;
  # platform/darwin never reaches into desktop.
  imports = [
    ./browser/darwin.nix
    ./ai/darwin.nix
    ./terminal/ghostty/darwin.nix
    ./terminal/kitty/darwin.nix
    ./keymap/karabiner/darwin.nix
    ./network/tailscale/darwin.nix
    ./menu-bar/ice/darwin.nix
    ./workspace/darwin.nix
  ];
}
