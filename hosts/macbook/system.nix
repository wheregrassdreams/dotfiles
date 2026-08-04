{ ... }: {
  imports = [
    ../../modules/platform/nix.nix
    ../../modules/platform/determinate.nix
    ../../modules/platform/darwin
    ./preferences/system.nix
  ];
}
