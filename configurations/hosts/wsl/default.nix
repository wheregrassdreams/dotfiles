rec {
  system = "x86_64-linux";
  # Keep shared personal metadata while using the dedicated WSL account.
  identity = (import ../../profiles/me.nix) // {
    username = "zane";
  };
  userName = identity.username;
  hostName = "nixos";
  dotfilesPath = "/home/nixos/dotfiles";
  isWsl = true;
  hostModule = ./system.nix;
  systemModules = [ ];
  homeModules = [ ./home.nix ];
}
