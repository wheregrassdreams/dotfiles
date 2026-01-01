{ ... }: {
  imports = [
    ./desktop/boot.nix
    ./desktop/console.nix
    ./desktop/environment.nix
    ./desktop/file-systems.nix
    ./desktop/fonts.nix
    ./desktop/hardware.nix
    ./desktop/location.nix
    ./desktop/networking.nix
    ./desktop/programs.nix
    ./desktop/services.nix
    ./desktop/swap-devices.nix
    ./desktop/users.nix
    ./desktop/virtualisation.nix
    ./desktop/xdg.nix
  ];
}
