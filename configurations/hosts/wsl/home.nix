{ identity, ... }: {
  imports = [
    ../../../modules/home
    ../../../modules/home/data/home.nix
    ../../../modules/home/services
    ../../profiles/minimal-terminal/home.nix
  ];

  my.identity = identity;
}
