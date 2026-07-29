{ ... }: {
  imports = [
    ../../modules/user
    ../../modules/backing-services/default.nix
    ../../modules/backing-services/home.nix
    ../../profiles/minimal-terminal/home.nix
  ];
}
