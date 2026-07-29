{ ... }: {
  imports = [
    ../../modules/user
    ../../modules/data/home.nix
    ../../modules/services/home.nix
    ../../profiles/minimal-terminal/home.nix
  ];
}
