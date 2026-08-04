{ ... }: {
  imports = [
    ../../modules/user
    ../../modules/platform/darwin/homebrew-home.nix
    ../../modules/desktop/home.nix
    ../../modules/data/home.nix
    ../../modules/services/home.nix
    ../../modules/connectivity/tailscale/home.nix
    ../../profiles/personal-mac/home.nix
    ../../profiles/personal-mac/homebrew.nix
    ../../profiles/personal-mac/ai-home.nix
    ../../profiles/personal-mac/desktop.nix
    ../../profiles/personal-mac/data.nix
    ../../profiles/personal-mac/connectivity.nix
    ../../profiles/personal-mac/services.nix
    ../../profiles/work/home.nix
    ../../profiles/homelab/home.nix
    ./facts/home.nix
    ./home-settings.nix
    ./preferences/home.nix
    ./preferences/apps/karabiner.nix
  ];
}
