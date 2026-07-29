{ ... }: {
  imports = [
    ../../modules/platform/nix.nix
    ../../modules/platform/determinate.nix
    ../../modules/platform/darwin
    ../../modules/desktop/darwin.nix
    ../../modules/services/darwin.nix
    ../../modules/connectivity/tailscale/darwin.nix
    ../../profiles/personal-mac/system.nix
    ../../profiles/personal-mac/desktop.nix
    ../../profiles/personal-mac/connectivity.nix
    ../../profiles/personal-mac/services.nix
    ./preferences/system.nix
  ];
}
