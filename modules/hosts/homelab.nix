{ ... }: {
  imports = [
    ./homelab/boot.nix
    ./homelab/environment.nix
    ./homelab/file-systems.nix
    ./homelab/hardware.nix
    ./homelab/networking.nix
    ./homelab/services.nix
    ./homelab/users.nix
  ];
}
