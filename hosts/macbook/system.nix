{ ... }: {
  imports = [
    ../../modules/platform/nix.nix
    ../../modules/platform/determinate.nix
    ../../modules/platform/darwin
    ../../modules/desktop/darwin.nix
    ../../modules/backing-services/default.nix
    ../../modules/backing-services/darwin.nix
    ../../profiles/personal-mac/system.nix
    ../../profiles/personal-mac/ai.nix
    ../../profiles/personal-mac/desktop.nix
    ../../profiles/personal-mac/backing-services.nix
    ./preferences/system.nix
  ];
}
