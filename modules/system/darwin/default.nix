{ ... }: {
  imports = [
    ./base.nix
    ./homebrew.nix
    ./dock-implementation.nix
    ./disk-images.nix
  ];
}
