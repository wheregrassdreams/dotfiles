{ inputs ? {}, ... }: {
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ./wsl/virtualisation.nix
    ./wsl/wsl.nix
  ];
}
