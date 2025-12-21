{ ... }: {
  imports = [
    ./boot.nix
    ./environment.nix
    ./file-systems.nix
    ./hardware.nix
    ./networking.nix
    ./services.nix
    ./users.nix
  ];
}
