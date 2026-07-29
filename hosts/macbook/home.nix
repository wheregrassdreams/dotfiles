{ ... }: {
  imports = [
    ../../modules/user
    ../../modules/desktop/home.nix
    ../../modules/backing-services/default.nix
    ../../modules/backing-services/home.nix
    ../../profiles/personal-mac/home.nix
    ../../profiles/personal-mac/ai.nix
    ../../profiles/personal-mac/desktop.nix
    ../../profiles/personal-mac/backing-services.nix
    ../../profiles/work/home.nix
    ../../profiles/homelab/home.nix
    ./facts/home.nix
    ./home-settings.nix
    ./preferences/home.nix
    ./preferences/apps/karabiner.nix
  ];
}
