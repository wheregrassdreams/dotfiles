{ ... }: {
  imports = [
    ../options/data.nix
    ./backup/home.nix
    ./sync/home.nix
    ./export/home.nix
  ];
}
